//
//  MKTurn3DTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTurn3DTransition.h"

@implementation MKTurn3DTransition

+ (instancetype)turnDirection:(MKTurnDirection)turnDirection
{
    MKTurn3DTransition *turn = [self new];
    turn->_turnDirection     = turnDirection;
    return turn;
}

- (id)init
{
    if (self = [super init])
        _turnDirection = MKTurnDirectionVertical;
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    if (fromView == nil || toView == nil)
    {
        [self completeTransition:transitionContext];
        return;
    }
    
    // Add the toView to the container
    [containerView addSubview:toView];
    
    // Add a perspective transform
    CATransform3D transform = CATransform3DIdentity;
    transform.m34           = -0.002;
    [containerView.layer setSublayerTransform:transform];
    
    // Give both VCs the same start frame
    CGRect initialFrame     = [transitionContext initialFrameForViewController:fromViewController];
    fromView.frame          = initialFrame;
    toView.frame            = initialFrame;
    
    float factor = self.isPresenting ? -1.0 : 1.0;
    
    // flip the to VC halfway round - hiding it
    toView.layer.transform = [self rotate:factor * -M_PI_2];
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            // rotate the from view
            fromView.layer.transform = [self rotate:factor * M_PI_2];
            }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            // rotate the to view
            toView.layer.transform = [self rotate:0.0];
            }];
    } completion:^(BOOL finished) {
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

- (CATransform3D)rotate:(CGFloat)angle
{
    return (_turnDirection == MKTurnDirectionHorizontal)
         ? CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0)
         : CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
}

@end
