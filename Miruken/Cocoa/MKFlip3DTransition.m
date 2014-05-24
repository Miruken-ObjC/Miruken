//
//  MKFlip3DTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKFlip3DTransition.h"

#define kDefaultPerspective  (-1.0 / 500.0f)

@implementation MKFlip3DTransition
{
    MKStartingPosition _startingPosition;
}

+ (instancetype)turnFromPosition:(MKStartingPosition)position
{
    MKFlip3DTransition *turn = [self new];
    turn->_startingPosition  = position;
    return turn;
}

- (id)init
{
    if (self = [super init])
    {
        _startingPosition = MKStartingPositionTop;
        _perspective      = kDefaultPerspective;
    }
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
    
    MKStartingPosition startingPosition = self.isPresenting
                                        ? _startingPosition
                                        : [self inverseStartingPosition:_startingPosition];
    
    // Add the toView to the container
    [containerView addSubview:toView];
    
    // Add a perspective transform
    CATransform3D transform = CATransform3DIdentity;
    transform.m34           = _perspective;
    [containerView.layer setSublayerTransform:transform];
    
    // Give both VCs the same start frame
    CGRect initialFrame     = [transitionContext initialFrameForViewController:fromViewController];
    fromView.frame          = initialFrame;
    toView.frame            = initialFrame;
    
    // flip the to VC halfway round - hiding it
    toView.layer.transform  = [self rotate:-M_PI_2 startingPosition:startingPosition];
    toView.hidden           = YES;
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    NSTimeInterval halfway  = duration / 2.0;
    
    [UIView animateWithDuration:halfway delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
        fromView.layer.transform = [self rotate:M_PI_2 startingPosition:startingPosition];
    } completion:^(BOOL finished) {
        fromView.hidden = YES;
        toView.hidden   = NO;
    }];
    
    [UIView animateWithDuration:halfway delay:halfway
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        toView.layer.transform = [self rotate:0.0 startingPosition:startingPosition];
    } completion:^(BOOL finished) {
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

- (CATransform3D)rotate:(CGFloat)angle startingPosition:(MKStartingPosition)startingPosition
{
    switch (startingPosition) {
        case MKStartingPositionLeft:
            return CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
            
        case MKStartingPositionRight:
            return CATransform3DMakeRotation(angle, 0.0, -1.0, 0.0);
            
        case MKStartingPositionBottom:
            return CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
            
        case MKStartingPositionBottomLeft:
            return CATransform3DMakeRotation(angle, 1.0, 1.0, 0.0);
            
        case MKStartingPositionBottomRight:
            return CATransform3DMakeRotation(angle, 1.0, -1.0, 0.0);
            
        case MKStartingPositionTop:
            return CATransform3DMakeRotation(angle, -1.0, 0.0, 0.0);
            
        case MKStartingPositionTopLeft:
            return CATransform3DMakeRotation(angle, -1.0, 1.0, 0.0);
            
        case MKStartingPositionTopRight:
            return CATransform3DMakeRotation(angle, -1.0, -1.0, 0.0);
    }
}

@end
