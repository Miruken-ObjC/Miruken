//
//  MKFlipHorizontalTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKFlipHorizontalTransition.h"

@implementation MKFlipHorizontalTransition

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source
{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.7f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView           *containerView      = [transitionContext containerView];
    UIViewController *fromViewController =
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [containerView addSubview:fromViewController.view];
    
    UIViewController *toViewController   =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [containerView addSubview:toViewController.view];
    
    UIViewAnimationOptions animationOption
        = [toViewController.presentedViewController isEqual:fromViewController]
        ? UIViewAnimationOptionTransitionFlipFromLeft
        : UIViewAnimationOptionTransitionFlipFromRight;
    
    [UIView transitionFromView:fromViewController.view
                        toView:toViewController.view
                      duration:[self transitionDuration:transitionContext]
                       options:animationOption
                    completion:^(BOOL finished) {
                        [transitionContext completeTransition:YES];
                    }];
}

@end
