//
//  MKPushMoveInTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPushMoveInTransition.h"

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
    return push;
}

+ (instancetype)moveInFromPosition:(MKStartingPosition)position
{
    MKPushMoveInTransition *moveIn = [self new];
    moveIn->_push                  = NO;
    moveIn->_startingPosition      = position;
    moveIn->_fadeStyle             = MKTransitionFadeStyleNone;
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
    
    [self fadeFromView:fromView toView:toView initial:YES];
    
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:0 animations:^{
                           [self fadeFromView:fromView toView:toView initial:NO];
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

- (void)fadeFromView:(UIView *)fromView toView:(UIView *)toView initial:(BOOL)initial
{
    initial = self.isPresenting ? initial : !initial;
    if (_fadeStyle == MKTransitionFadeStyleIn || _fadeStyle == MKTransitionFadeStyleInOut)
        toView.alpha = initial ? 0.0 : 1.0;
    else if (_fadeStyle == MKTransitionFadeStyleInOut || _fadeStyle == MKTransitionFadeStyleInOut)
        fromView.alpha = initial ? 1.0 : 0.0;
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
