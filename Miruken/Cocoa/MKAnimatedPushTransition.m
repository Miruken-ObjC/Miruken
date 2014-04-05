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
    MKStartingPosition _startingPosition;
}

+ (instancetype)pushFromPosition:(MKStartingPosition)position;
{
    MKAnimatedPushTransition *push = [self new];
    push->_startingPosition        = position;
    return push;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    MKStartingPosition startingPosition = self.isPresenting == NO
                                        ? _startingPosition
                                        : [self inferInverseStartingPosition];
    
    if (fromView)
    {
        fromView.frame = containerView.bounds;
        [containerView addSubview:fromView];
    }
    
    [self setView:toView startingPosition:startingPosition inContainerView:containerView inverse:YES];
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:toView];
    
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:0 animations:^{
                           if (fromView)
                               [self setView:fromView startingPosition:startingPosition
                                    inContainerView:containerView inverse:NO];
                           toView.frame = containerView.frame;
                       } completion:^(BOOL finished) {
                           if (fromView)
                               [fromView removeFromSuperview];
                           [transitionContext completeTransition:finished];
                       }];
}

- (void)setView:(UIView *)view startingPosition:(MKStartingPosition)startingPosition
    inContainerView:(UIView *)containerView inverse:(BOOL)inverse
{
    CGRect    frame            = view.frame;
    NSInteger inverseMultipier = inverse ? -1 : 1;
    
    switch (_startingPosition) {
        case MKStartingPositionLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            break;
            
        case MKStartingPositionRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            break;

        case MKStartingPositionBottom:
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKStartingPositionBottomLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;

        case MKStartingPositionBottomRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKStartingPositionTop:
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
         
        case MKStartingPositionTopLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;

        case MKStartingPositionTopRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
    }
    
    frame.size = containerView.frame.size;
    view.frame = frame;
}

- (MKStartingPosition)inferInverseStartingPosition
{
    switch (_startingPosition) {
        case MKStartingPositionLeft:
            return MKStartingPositionRight;
            
        case MKStartingPositionRight:
            return MKStartingPositionLeft;
            
        case MKStartingPositionBottom:
            return MKStartingPositionTop;
            
        case MKStartingPositionBottomLeft:
            return MKStartingPositionTopRight;
            
        case MKStartingPositionBottomRight:
            return MKStartingPositionTopLeft;
            
        case MKStartingPositionTop:
            return MKStartingPositionBottom;
            
        case MKStartingPositionTopLeft:
            return MKStartingPositionBottomRight;
            
        case MKStartingPositionTopRight:
            return MKStartingPositionBottomLeft;
    }
}

@end
