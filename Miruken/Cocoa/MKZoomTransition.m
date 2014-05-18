//
//  MKZoomTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/6/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKZoomTransition.h"

#define kZoomAnimationDuration (0.4f)

@implementation MKZoomTransition

- (id)init
{
    if (self = [super init])
        self.animationDuration = kZoomAnimationDuration;
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    if (self.isPresenting)
    {
        toView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        if (fromView)
            [containerView insertSubview:toView aboveSubview:fromView];
        else
            [containerView addSubview:toView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            BOOL cancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancelled];
        }];
    }
    else
    {
        if (toView)
            [containerView insertSubview:toView belowSubview:fromView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        } completion:^(BOOL finished) {
            BOOL cancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancelled];
        }];
    }
}

@end
