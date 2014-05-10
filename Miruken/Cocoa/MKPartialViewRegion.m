//
//  MKPartialViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPartialViewRegion.h"
#import "MKDynamicCallbackHandler.h"
#import "MKContextualHelper.h"
#import "MKPresentationPolicy.h"
#import "MKTransitionContext.h"
#import "MKCallbackHandler+Resolvers.h"
#import "MKContext+Subscribe.h"
#import "NSObject+NotHandled.h"
#import "NSObject+Context.h"
#import "MKCocoaErrors.h"
#import "MKDeferred.h"
#import "EXTScope.h"

@interface MKPartialTransitionContext : MKTransitionContext
@end

@implementation MKPartialViewRegion
{
    MKContext                  *_context;
    UIViewController           *_controller;
    MKPartialTransitionContext *_transition;
    UIView                     *_transitionView;
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
        {
            return [[MKDeferred rejected:[NSError errorWithDomain:MKCocoaErrorDomain
                                                             code:MKCocoaErrorTransitionInProgress
                                                         userInfo:nil]] promise];
        }
        
        _transition = [self partialTransitionTo:viewController];
        [self removePartialController];
        [self addPartialController];
        return [_transition pipe:^(id result) { return viewController.context; }];
    }
    
    return [self notHandled];
}

- (MKPartialTransitionContext *)partialTransitionTo:(UIViewController *)toViewController
{
    if (_transitionView == nil)
    {
        _transitionView = [[UIView alloc] initWithFrame:self.bounds];
        _transitionView.clipsToBounds                             = YES;
        _transitionView.translatesAutoresizingMaskIntoConstraints = NO;
        _transitionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_transitionView];
    }

    return [MKPartialTransitionContext transitionContainerView:_transitionView
                                            fromViewController:_controller
                                              toViewController:toViewController];
}

- (void)addPartialController
{
    UIViewController *toViewController = _transition.toViewController;
    
    if (toViewController)
    {
        @weakify(self);
        __weak MKPartialTransitionContext *transition = _transition;
        [[MKContextualHelper bindChildContextFrom:self.context toChild:toViewController]
            subscribeDidEnd:^(id<MKContext> context) {
                @strongify(self);
                if (_transition == nil || _transition == transition)
                {
                    _transition = [self partialTransitionTo:nil];
                    [self removePartialController];
                }
            }];

        UIViewController *owningController = [self owningViewController];
        [toViewController willMoveToParentViewController:owningController];
        [owningController  addChildViewController:toViewController];
        [toViewController didMoveToParentViewController:owningController];
        
        UIView *partialView = toViewController.view;
        partialView.frame   = self.bounds;
        [self addSubview:partialView];
        
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
            [_transition animateTranstion];
        
        _controller = nil;
    }
}

- (void)completeTransition:(BOOL)didComplete
{
    if (didComplete)
    {
        UIView *toView = _transition.toViewController.view;
        toView.translatesAutoresizingMaskIntoConstraints = NO;
        toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    [_transition.fromViewController.view removeFromSuperview];
    _transition = nil;
}

- (void)dealloc
{
    [_context end];
    _context = nil;
}

@end

#pragma mark - MKPartialTransitionContext

@implementation MKPartialTransitionContext

- (void)completeTransition:(BOOL)didComplete
{
    [(MKPartialViewRegion *)self.containerView completeTransition:didComplete];
}

@end