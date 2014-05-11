//
//  MKPartialViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPartialViewRegion.h"
#import "MKViewControllerWapperView.h"
#import "MKDynamicCallbackHandler.h"
#import "MKContextualHelper.h"
#import "MKPresentationPolicy.h"
#import "MKTransitionContext.h"
#import "MKCallbackHandler+Resolvers.h"
#import "MKContext+Subscribe.h"
#import "NSObject+NotHandled.h"
#import "NSObject+Context.h"
#import "MKCocoaErrors.h"
#import "EXTScope.h"

@interface MKPartialViewRegion()
@property (weak, nonatomic) MKTransitionContext *transition;
@end

@implementation MKPartialViewRegion
{
    MKContext                         *_context;
    UIViewController                  *_controller;
    __weak UIView                     *_transitionView;
    __weak MKViewControllerWapperView *_wrapperView;
}

- (id)init
{
    if (self = [super init])
        [self initPartialViewRegion];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self initPartialViewRegion];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self initPartialViewRegion];
    return self;
}

- (void)initPartialViewRegion
{
    UIView *transitionView          = [[UIView alloc] initWithFrame:self.bounds];
    transitionView.clipsToBounds    = YES;
    transitionView.autoresizingMask = UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_transitionView = transitionView];
}

- (id)controller
{
    return _controller;
}

- (MKContext *)context
{
    if (_context == nil)
    {
        UIViewController<MKContextual> *owningController = [self owningViewController];
        _context                                         = [owningController.context newChildContext];
        [_context addHandler:[MKDynamicCallbackHandler delegateTo:self]];
    }
    return _context;
}

- (MKPresentationPolicy *)presentationPolicy
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    return [self.composer handle:presentationPolicy greedy:YES]
         ? presentationPolicy
         : nil;
}

- (UIViewController<MKContextual> *)owningViewController
{
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
        if ([nextResponder isKindOfClass:UIViewController.class])
            return nextResponder;
    return nil;
}

#pragma mark - MKViewRegion

- (id<MKPromise>)presentViewController:(UIViewController<MKContextual> *)viewController
{
    MKCallbackHandler    *composer           = self.composer;
    MKPresentationPolicy *presentationPolicy = [self presentationPolicy];
    [presentationPolicy applyPolicyToViewController:viewController];
    
    if (presentationPolicy.isModal == NO)
    {
        if (self.context != composer)
        {
            UIViewController       *owner = [composer getClass:UIViewController.class orDefault:nil];
            UINavigationController *navigationController = owner.navigationController;
            
            if (navigationController)
            {
                [navigationController pushViewController:viewController animated:YES];
                return [[MKDeferred resolved:viewController.context] promise];
            }
        }
        
        if (_transition)
            return [[MKDeferred rejected:[NSError errorWithDomain:MKCocoaErrorDomain
                                                             code:MKCocoaErrorTransitionInProgress
                                                         userInfo:nil]] promise];
        
        _transition = [self partialTransitionTo:viewController];
        [self removePartialController];
        [self addPartialController];
        return [_transition pipe:^(NSNumber *didComplete) {
            return viewController.context;
        }];
    }
    
    return [self notHandled];
}

- (MKTransitionContext *)partialTransitionTo:(UIViewController *)toViewController
{
    if (_wrapperView == nil)
    {
        _wrapperView = [MKViewControllerWapperView wrapperViewForView:toViewController.view
                                                                frame:_transitionView.bounds];
        [_transitionView addSubview:_wrapperView];
    }
    return [MKTransitionContext transitionContainerView:_wrapperView
                                     fromViewController:_controller
                                       toViewController:toViewController];
}

- (void)addPartialController
{
    UIViewController *toViewController = _transition.toViewController;
    
    if (toViewController)
    {
        @weakify(self);
        __weak MKTransitionContext *transition = _transition;
        [[MKContextualHelper bindChildContextFrom:self.context toChild:toViewController]
            subscribeDidEnd:^(id<MKContext> context) {
                @strongify(self);
                if (self.transition == nil || self.transition == transition)
                {
                    self.transition = [self partialTransitionTo:nil];
                    [self removePartialController];
                }
            }];

        UIViewController *owningController = [self owningViewController];
        [toViewController willMoveToParentViewController:owningController];
        [owningController  addChildViewController:toViewController];
        [toViewController didMoveToParentViewController:owningController];
        
        [_transition animateTranstion];
        _controller = toViewController;
    }
}

- (void)removePartialController
{
    UIViewController *fromViewController = _transition.fromViewController;
    
    if (fromViewController)
    {
        [fromViewController willMoveToParentViewController:nil];
        [fromViewController removeFromParentViewController];
        [fromViewController didMoveToParentViewController:nil];
        
        if (_transition.isPresenting == NO)
        {
            [_transition animateTranstion];
            [_wrapperView removeFromSuperview];
            _wrapperView = nil;
        }
        
        _controller = nil;
    }
}

- (void)dealloc
{
    [_context end];
    _context = nil;
}

@end
