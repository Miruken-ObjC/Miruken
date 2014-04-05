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
    MKViewStartingPosition _position;
}

+ (instancetype)pushFromPosition:(MKViewStartingPosition)position;
{
    MKAnimatedPushTransition *push = [self new];
    push->_position                = position;
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
    
    [self setViewFrame:toView containerView:containerView inverse:YES];
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:toView];
    
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:0 animations:^{
                           if (fromView)
                               [self setViewFrame:fromView containerView:containerView inverse:NO];
                           toView.frame = containerView.frame;
                       } completion:^(BOOL finished) {
                           if (fromView)
                               [fromView removeFromSuperview];
                           [transitionContext completeTransition:finished];
                       }];
}

- (void)setViewFrame:(UIView *)view containerView:(UIView *)containerView inverse:(BOOL)inverse
{
    CGRect    frame            = view.frame;
    NSInteger inverseMultipier = inverse ? -1 : 1;
    
    switch (_position) {
        case MKViewStartingPositionLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            break;
            
        case MKViewStartingPositionRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            break;

        case MKViewStartingPositionBottom:
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKViewStartingPositionBottomLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;

        case MKViewStartingPositionBottomRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKViewStartingPositionTop:
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
         
        case MKViewStartingPositionTopLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;

        case MKViewStartingPositionTopRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
    }
    
    frame.size = containerView.frame.size;
    view.frame = frame;
}

@end
