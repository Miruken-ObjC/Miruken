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
#import "MKTransitionOptions.h"
#import "MKTransitionContext.h"
#import "MKCallbackHandler+Resolvers.h"
#import "MKContext+Subscribe.h"
#import "NSObject+Context.h"
#import "MKCocoaErrors.h"
#import "MKMixin.h"
#import "EXTScope.h"

@interface MKPartialViewRegion()
@property (weak, nonatomic) MKTransitionContext *transition;
@end

@implementation MKPartialViewRegion
{
    MKContext                         *_context;
    UIViewController                  *_controller;
    __weak MKViewControllerWapperView *_wrapperView;
}

+ (void)initialize
{
    if (self == MKPartialViewRegion.class)
        [self mixinFrom:MKViewRegionSubclassing.class];
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
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    MKViewControllerWapperView *wrapperView = [[MKViewControllerWapperView alloc] initWithFrame:self.bounds];
    [self addSubview:wrapperView];
    _wrapperView = wrapperView;
}

- (id)controller
{
    return _controller;
}

- (MKContext *)context
{
    if (_context == nil)
    {
        UIViewController<MKContextual> *owningController = [self _owningViewController];
        _context                                         = [owningController.context newChildContext];
        [_context addHandler:[MKDynamicCallbackHandler delegateTo:self]];
    }
    return _context;
}

- (UIViewController<MKContextual> *)_owningViewController
{
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
        if ([nextResponder isKindOfClass:UIViewController.class])
            return nextResponder;
    return nil;
}

#pragma mark - MKViewRegionSubclassing

- (BOOL)canPresentWithMKTransitionOptions:(MKTransitionOptions *)options
{
    return YES;
}

- (id<MKPromise>)presentViewController:(UIViewController<MKContextual> *)viewController
                            withPolicy:(MKPresentationPolicy *)policy
{
    MKCallbackHandler *composer = self.composer;
    [policy applyPolicyToViewController:viewController];
    
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
    
    _transition = [self _partialTransitionTo:viewController];
    [self _removePartialController];
    [self _addPartialController];
    return [_transition pipe:^(NSNumber *didComplete) {
        return viewController.context;
    }];
}

- (MKTransitionContext *)_partialTransitionTo:(UIViewController *)toViewController
{
    return [MKTransitionContext transitionContainerView:_wrapperView
                                     fromViewController:_controller
                                       toViewController:toViewController];
}

- (void)_addPartialController
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
                    self.transition = [self _partialTransitionTo:nil];
                    [self _removePartialController];
                }
            }];

        UIViewController *owningController = [self _owningViewController];
        [owningController  addChildViewController:toViewController];
        [toViewController didMoveToParentViewController:owningController];
        [_wrapperView wrapView:toViewController.view];
        
        [_transition animateTranstion];
        _controller = toViewController;
    }
}

- (void)_removePartialController
{
    UIViewController *fromViewController = _transition.fromViewController;
    
    if (fromViewController)
    {
        [fromViewController willMoveToParentViewController:nil];
        [fromViewController removeFromParentViewController];
        
        if (_transition.isPresenting == NO)
            [_transition animateTranstion];
        
        _controller = nil;
    }
}

- (void)dealloc
{
    [_context end];
    _context = nil;
}

@end
