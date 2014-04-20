//
//  MKFlipHorizontalTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKModalFlipHorizontalTransition.h"

@implementation MKModalFlipHorizontalTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
    
    UIViewAnimationOptions animationOption
                         = self.isPresenting == NO
                         ? UIViewAnimationOptionTransitionFlipFromLeft
                         : UIViewAnimationOptionTransitionFlipFromRight;
    
    [UIView transitionFromView:fromViewController.view
                        toView:toViewController.view
                      duration:[self transitionDuration:transitionContext]
                       options:animationOption
                    completion:^(BOOL finished) {
                        BOOL cancelled = [transitionContext transitionWasCancelled];
                        [transitionContext completeTransition:!cancelled];
                    }];
}

@end
