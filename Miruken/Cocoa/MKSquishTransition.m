//
//  MKSquishTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 7/6/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Simon Fairbairn on 17/10/2013.
//

#import "MKSquishTransition.h"

#define kSquishAnimationDuration (1.0f)

@implementation MKSquishTransition

- (id)init
{
    if (self = [super init])
        self.animationDuration = kSquishAnimationDuration;
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    if (self.isPresenting)
    {
        [self _animatePresentation:transitionContext
               fromViewController:fromViewController
                 toViewController:toViewController];
    }
    else
    {
        [self _animateDismissal:transitionContext
            fromViewController:fromViewController
              toViewController:toViewController];
    }
}

- (void)_animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
          fromViewController:(UIViewController *)fromViewController
            toViewController:(UIViewController *)toViewController
{
    UIView *fromView          = fromViewController.view;
    UIView *toView            = toViewController.view;
    UIView *containerView     = [transitionContext containerView];
    
    toView.frame = ({
        CGRect frame   = toView.frame;
        frame.origin.x = -frame.size.width;
        frame;
    });
    [containerView addSubview:toView];
    
    CGRect  initialFrame      = containerView.bounds;
    UIView *blackView         = fromView ? [[UIView alloc] initWithFrame:initialFrame] : nil;
    blackView.backgroundColor = [UIColor blackColor];
    UIView *snapshot          = [toView snapshotViewAfterScreenUpdates:YES];
    [containerView addSubview:snapshot];
    
    if (blackView)
    {
        [containerView insertSubview:blackView belowSubview:fromView];
        [containerView sendSubviewToBack:toView];
    }
    else
        [toView removeFromSuperview];
    
    CGRect snapshotFrame        = initialFrame;
    snapshotFrame.origin.y      = CGRectGetHeight(initialFrame);
    snapshotFrame.origin.x      = CGRectGetMidX(initialFrame) - 5.0;
    snapshotFrame.size.width    = 10.0f;
    snapshot.frame              = snapshotFrame;

    NSTimeInterval duration     = [self transitionDuration:transitionContext];

    [UIView animateKeyframesWithDuration:duration delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.6f animations:^{
            fromView.alpha           = 0.7f;
            CGRect snapshotFrame     = snapshot.frame;
            snapshotFrame.origin.y   = 0.0f;
            snapshot.frame           = snapshotFrame;
        }];
                                  
        [UIView addKeyframeWithRelativeStartTime:0.6f relativeDuration:0.3f animations:^{
            CGRect snapshotFrame     = snapshot.frame;
            snapshotFrame.origin.x   = 0.0f;
            snapshotFrame.size.width = CGRectGetWidth(initialFrame);
            snapshot.frame           = snapshotFrame;
            fromView.alpha           = 0.0f;
        }];
    } completion:^(BOOL finished) {
        toView.frame = initialFrame;
        [containerView addSubview:toView];
        [fromView removeFromSuperview];
        [snapshot removeFromSuperview];
        [blackView removeFromSuperview];
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

- (void)_animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *fromView            = fromViewController.view;
    UIView *toView              = toViewController.view;
    UIView *containerView       = [transitionContext containerView];

    CGRect initialFrame         = [transitionContext initialFrameForViewController:fromViewController];

    if (toView)
    {
        toView.frame             = initialFrame;
        toView.alpha             = 0.2f;
        [containerView addSubview:toView];
    }
    fromView.hidden             = YES;

    CGAffineTransform transform = fromView.transform;
    UIView *snapshot            = [fromView snapshotViewAfterScreenUpdates:NO];
    snapshot.transform          = transform;
    [containerView addSubview:snapshot];
    
    NSTimeInterval duration     = [self transitionDuration:transitionContext];

    [UIView animateKeyframesWithDuration:duration delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.6f animations:^{
            toView.alpha             = 0.6f;
            CGRect snapshotFrame     = snapshot.frame;
            snapshotFrame.origin.x   = CGRectGetMidX(initialFrame) - 5.0f;
            snapshotFrame.size.width = 10.0f;
            snapshot.frame           = snapshotFrame;
        }];
                                  
        [UIView addKeyframeWithRelativeStartTime:0.6f relativeDuration:0.4f animations:^{
            CGRect snapshotFrame     = snapshot.frame;
            snapshotFrame.origin.y   = CGRectGetHeight(initialFrame);
            snapshotFrame.size.width = 5.0f;
            snapshot.frame           = snapshotFrame;
            toView.alpha             = 1.0f;
        }];
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        [snapshot removeFromSuperview];
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

@end
