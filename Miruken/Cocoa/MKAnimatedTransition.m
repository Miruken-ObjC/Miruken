//
//  MKAnimatedTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransition.h"

#define kDefaultAnimationDuration (0.7f)

@implementation MKAnimatedTransition

- (id)init
{
    if (self = [super init])
        _animationDuration = kDefaultAnimationDuration;
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source
{
    _isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed
{
    _isPresenting = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController =
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [self animateTransition:transitionContext fromViewController:fromViewController
           toViewController:toViewController];
}

- (void)completeTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController =
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (toViewController.view)
        [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController.view removeFromSuperview];
    BOOL cancelled = [transitionContext transitionWasCancelled];
    [transitionContext completeTransition:!cancelled];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
}

@end
