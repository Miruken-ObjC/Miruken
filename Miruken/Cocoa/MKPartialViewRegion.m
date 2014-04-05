//
//  MKPartialViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPartialViewRegion.h"
#import "MKDynamicCallbackHandler.h"
#import "MKContextual.h"
#import "MKContextualHelper.h"
#import "MKPresentationPolicy.h"
#import "MKTransitionContext.h"
#import "MKContext+Subscribe.h"
#import "NSObject+NotHandled.h"
#import "MKCallbackHandler+Resolvers.h"
#import "NSObject+Context.h"
#import "EXTScope.h"

@interface MKPartialTransitionContext : MKTransitionContext
@end

@implementation MKPartialViewRegion
{
    MKContext        *_context;
    UIViewController *_controller;
    NSArray          *_constraints;
    BOOL              _transitioning;
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

- (id)controller
{
    return _controller;
}

- (MKPresentationPolicy *)presentationPolicy
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    return [self.composer handle:presentationPolicy greedy:YES]
         ? presentationPolicy
         : nil;
}

#pragma mark - MKViewRegion

- (void)presentViewController:(UIViewController *)viewController
{
    self.clipsToBounds                       = YES;
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
                return;
            }
        }
        
        _transitioning = (_controller != nil);
        BOOL animated  = (viewController.transitioningDelegate != nil);
        [self removePartialControllerAnimated:animated];
        [self addPartialController:viewController animated:animated];
        return;
    }
    
    [self notHandled];
}

- (UIViewController<MKContextual> *)owningViewController
{
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
        if ([nextResponder isKindOfClass:UIViewController.class])
            return nextResponder;
    return nil;
}

- (void)addPartialController:(UIViewController *)partialController animated:(BOOL)animated
{
    if (partialController)
    {
        @weakify(self);
        UIViewController *owningController = [self owningViewController];
        MKContext        *partialContext   = [MKContextualHelper bindChildContextFrom:self.context
                                                                              toChild:partialController];
        [partialContext subscribeDidEnd:^(id<MKContext> context) {
            @strongify(self);
            if (self->_transitioning == NO)
                [self removePartialControllerAnimated:YES];
        }];

        [partialController willMoveToParentViewController:owningController];
        [owningController  addChildViewController:partialController];
        [partialController didMoveToParentViewController:owningController];
        
        UIView *partialView = partialController.view;
        [partialView removeConstraints:partialView.constraints];
        partialView.frame   = self.bounds;
        [self addSubview:partialView];
        
        if (animated)
            [self animateFromViewController:_controller
                           toViewController:partialController
                                 presenting:YES];
        else
            [self completeTransitionFromViewController:_controller
                                      toViewController:partialController
                                              animated:animated];
        
        _controller = partialController;
    }
}

- (void)animateFromViewController:(UIViewController *)fromViewController
                 toViewController:(UIViewController *)toViewController
                       presenting:(BOOL)presenting
{
    MKPartialTransitionContext *partialTransition =
        [MKPartialTransitionContext transitionContainerView:self
                                         fromViewController:fromViewController
                                           toViewController:toViewController];
    
    id<UIViewControllerAnimatedTransitioning> transitionController = presenting
        ? [toViewController.transitioningDelegate
           animationControllerForPresentedController:toViewController
                                presentingController:fromViewController
                                    sourceController:fromViewController]
        : [fromViewController.transitioningDelegate
           animationControllerForDismissedController:fromViewController];
    
    [transitionController animateTransition:partialTransition];
}

- (void)completeTransitionFromViewController:(UIViewController *)fromViewController
                            toViewController:(UIViewController *)toViewController
                                    animated:(BOOL)animated
{
    _transitioning = NO;
    if (toViewController)
        [self bindPartialViewToRegion:toViewController.view];
    [fromViewController.view removeFromSuperview];
}

- (void)removePartialControllerAnimated:(BOOL)animated
{
    if (_controller)
    {
        if (_constraints)
            [self removeConstraints:_constraints];

        animated = animated && _controller.transitioningDelegate;
        
        [_controller willMoveToParentViewController:nil];
        [_controller removeFromParentViewController];
        [_controller didMoveToParentViewController:nil];
        
        if (animated && _transitioning == NO)
            [self animateFromViewController:_controller toViewController:nil presenting:NO];
        else if (_transitioning == NO)
        {
            [_controller.view removeFromSuperview];
            _controller = nil;
        }
    }
}

- (void)bindPartialViewToRegion:(UIView *)view
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    _constraints = [[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                            options:0 metrics:nil views:views]
            arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                            options:0 metrics:nil views:views]];
    [self addConstraints:_constraints];
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
    [(MKPartialViewRegion *)self.containerView
        completeTransitionFromViewController:self.fromViewController
                            toViewController:self.toViewController
                                    animated:YES];
}

@end