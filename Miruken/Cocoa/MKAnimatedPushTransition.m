//
//  MKAnimatedPushTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedPushTransition.h"

@implementation MKAnimatedPushTransition
{
    MKTransitionDirection _direction;
}

+ (instancetype)pushDirection:(MKTransitionDirection)direction
{
    MKAnimatedPushTransition *push = [self new];
    push->_direction               = direction;
    return push;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    if (fromView)
    {
        fromView.frame = containerView.bounds;
        [containerView addSubview:fromView];
    }
    
    [self setViewFrame:toView containerView:containerView end:NO];
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:toView];
    
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:0 animations:^{
                           if (fromView)
                              [self setViewFrame:fromView containerView:containerView end:YES];
                           toView.frame = containerView.frame;
                       } completion:^(BOOL finished) {
                           if (fromView)
                               [fromView removeFromSuperview];
                           [transitionContext completeTransition:finished];
                       }];
}

- (void)setViewFrame:(UIView *)view containerView:(UIView *)containerView end:(BOOL)end
{
    CGRect    frame   = view.frame;
    NSInteger inverse = end ? 1 : -1;
    
    switch (_direction) {
        case MKTransitionDirectionUp:
            frame.origin.y = -containerView.frame.size.height * inverse;
            break;
            
        case MKTransitionDirectionDown:
            frame.origin.y = containerView.frame.size.height * inverse;
            break;
            
        case MKTransitionDirectionLeft:
            frame.origin.x = -containerView.frame.size.width * inverse;
            break;
            
        case MKTransitionDirectionRight:
            frame.origin.x = containerView.frame.size.width * inverse;
            break;
    }
    
    frame.size = containerView.frame.size;
    view.frame = frame;
}

@end
