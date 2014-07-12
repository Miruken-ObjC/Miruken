//
//  MKAnimatedTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransition.h"

#define kDefaultAnimationDuration (0.7f)

@implementation MKAnimatedTransition

- (id)init
{
    if (self = [super init])
    {
        _animationDuration = kDefaultAnimationDuration;
        _clipToBounds      = YES;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source
{
    _isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed
{
    _isPresenting = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController =
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [transitionContext containerView].clipsToBounds = _clipToBounds;
    
    [self animateTransition:transitionContext fromViewController:fromViewController
           toViewController:toViewController];
}

- (void)completeTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController =
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [transitionContext containerView].clipsToBounds = YES;
    
    if (toViewController.view)
        [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController.view removeFromSuperview];
    
    BOOL cancelled = [transitionContext transitionWasCancelled];
    [transitionContext completeTransition:!cancelled];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
}

- (CGFloat)randomFloatBetween:(float)smallNumber and:(float)bigNumber
{
    CGFloat diff = bigNumber - smallNumber;
    return (((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (void)fade:(MKTransitionFadeStyle)fadeStyle fromView:(UIView *)fromView toView:(UIView *)toView
     initial:(BOOL)initial
{
    fadeStyle = self.isPresenting ? fadeStyle : [self inverseFadeStyle:fadeStyle];
    
    if (fadeStyle == MKTransitionFadeStyleIn || fadeStyle == MKTransitionFadeStyleInOut)
        toView.alpha = initial ? 0.0 : 1.0;
    
    if (fadeStyle == MKTransitionFadeStyleOut || fadeStyle == MKTransitionFadeStyleInOut)
        fromView.alpha = initial ? 1.0 : 0.0;
}

- (MKTransitionFadeStyle)inverseFadeStyle:(MKTransitionFadeStyle)fadeStyle
{
    switch (fadeStyle) {
        case MKTransitionFadeStyleIn:
            return MKTransitionFadeStyleOut;
            
        case MKTransitionFadeStyleOut:
            return MKTransitionFadeStyleIn;
            
        default:
            return fadeStyle;
    }
}

- (MKStartingPosition)inverseStartingPosition:(MKStartingPosition)position
{
    switch (position) {
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
