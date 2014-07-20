//
//  MKHoverTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 7/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Simon Fairbairn on 07/03/2014.
//  Copyright (c) 2014 Simon Fairbairn. All rights reserved.
//

#import "MKHoverTransition.h"

#define kHoverAnimationDuration (1.0f)

@implementation MKHoverTransition

- (id)init
{
    if (self = [super init])
        self.animationDuration = kHoverAnimationDuration;
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    [containerView addSubview:toView];
    
    if (self.isPresenting)
        [containerView sendSubviewToBack:toView];
    
    toView.alpha     = 0.0f;
    toView.transform = self.isPresenting
                     ? CGAffineTransformMakeScale(0.8, 0.8)
                     : CGAffineTransformMakeScale(1.2, 1.2);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0 options:0 animations:^{
                         
        toView.alpha     = 1.0f;
        toView.transform = CGAffineTransformIdentity;
                         
        if (self.isPresenting)
            fromView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        else
        {
            fromView.alpha     = 0.0f;
            fromView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        }
    }
    completion:^(BOOL finished) {
        fromView.transform = CGAffineTransformIdentity;
        BOOL cancelled     = [transitionContext transitionWasCancelled];
        if (!cancelled)
            [fromView removeFromSuperview];
        [transitionContext completeTransition:!cancelled];
    }];
}

@end
