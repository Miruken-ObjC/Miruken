//
//  MKViewAnimationTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKViewAnimationTransition.h"

@implementation MKViewAnimationTransition
{
    UIViewAnimationOptions _animationOptions;
}

+ (instancetype)transitionWithOptions:(UIViewAnimationOptions)options
{
    MKViewAnimationTransition *transition = [self new];
    transition->_animationOptions         = options;
    return transition;
}

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
    
    [UIView transitionFromView:fromViewController.view
                        toView:toViewController.view
                      duration:[self transitionDuration:transitionContext]
                       options:_animationOptions
                    completion:^(BOOL finished) {
                        [transitionContext completeTransition:finished];
                    }];
}

@end
