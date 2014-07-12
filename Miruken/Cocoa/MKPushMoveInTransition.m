//
//  MKPushMoveInTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPushMoveInTransition.h"

#define kPushAnimationDuration (0.5f)
#define kMoveAnimationDuration (0.4f)

@implementation MKPushMoveInTransition
{
    BOOL               _push;
    MKStartingPosition _startingPosition;
}

+ (instancetype)pushFromPosition:(MKStartingPosition)position;
{
    MKPushMoveInTransition *push = [self new];
    push->_push                  = YES;
    push->_startingPosition      = position;
    push->_fadeStyle             = MKTransitionFadeStyleNone;
    push.animationDuration       = kPushAnimationDuration;
    return push;
}

+ (instancetype)moveInFromPosition:(MKStartingPosition)position
{
    MKPushMoveInTransition *moveIn = [self new];
    moveIn->_push                  = NO;
    moveIn->_startingPosition      = position;
    moveIn->_fadeStyle             = MKTransitionFadeStyleNone;
    moveIn.animationDuration       = kMoveAnimationDuration;
    return moveIn;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    MKStartingPosition startingPosition = self.isPresenting
                                        ? _startingPosition
                                        : [self inverseStartingPosition:_startingPosition];
    
    if (fromView)
    {
        fromView.frame = containerView.bounds;
        [containerView addSubview:fromView];
    }
    
    [self _setView:toView startingPosition:startingPosition inContainerView:containerView inverse:NO];
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:toView];

    [self fade:_fadeStyle fromView:fromView toView:toView initial:YES];
    
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:0 animations:^{
                           [self fade:_fadeStyle fromView:fromView toView:toView initial:NO];
                           if ((_push || self.isPresenting == NO) && fromView)
                               [self _setView:fromView startingPosition:startingPosition
                                    inContainerView:containerView inverse:YES];
                           toView.frame = containerView.frame;
                       } completion:^(BOOL finished) {
                           [fromView removeFromSuperview];
                           BOOL cancelled = [transitionContext transitionWasCancelled];
                           [transitionContext completeTransition:!cancelled];
                       }];
}

- (void)_setView:(UIView *)view startingPosition:(MKStartingPosition)startingPosition
    inContainerView:(UIView *)containerView inverse:(BOOL)inverse
{
    CGRect    frame            = view.frame;
    NSInteger inverseMultipier = inverse ? -1 : 1;
    
    switch (startingPosition) {
        case MKStartingPositionLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            break;
            
        case MKStartingPositionRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            break;

        case MKStartingPositionBottom:
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKStartingPositionBottomLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;

        case MKStartingPositionBottomRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKStartingPositionTop:
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
         
        case MKStartingPositionTopLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;

        case MKStartingPositionTopRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
    }
    
    frame.size = containerView.frame.size;
    view.frame = frame;
}

@end
