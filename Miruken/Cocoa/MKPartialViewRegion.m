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
#import "EXTScope.h"

@interface MKPartialTransitionContext : MKTransitionContext
@end

@implementation MKPartialViewRegion
{
    MKContext                  *_context;
    UIViewController           *_controller;
    NSArray                    *_constraints;
    MKPartialTransitionContext *_transition;
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
        
        [_transition cancelAnimation];
        _transition = [self partialTransitionTo:viewController];
        [self removePartialController];
        [self addPartialController];
        return;
    }
    
    [self notHandled];
}

- (MKPartialTransitionContext *)partialTransitionTo:(UIViewController *)toViewController
{
    return [MKPartialTransitionContext transitionContainerView:self
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
                if (_transition == transition)
                {
                    [transition cancelAnimation];
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
        if (_constraints)
        {
            [self removeConstraints:_constraints];
            _constraints = nil;
        }

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
        [self anchorPartialViewToRegion:_transition.toViewController.view];
    [_transition.fromViewController.view removeFromSuperview];
    _transition = nil;
}

- (void)anchorPartialViewToRegion:(UIView *)view
{
    if (view.superview == nil)
        return;
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
    [(MKPartialViewRegion *)self.containerView completeTransition:didComplete];
}

@end