//
//  MKTransitionContext.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/5/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTransitionContext.h"

@implementation MKTransitionContext
{
    UIView *_containerView;
    BOOL    _cancelled;
}

+ (instancetype)transitionContainerView:(UIView *)containerView
                     fromViewController:(UIViewController *)fromViewController
                       toViewController:(UIViewController *)toViewController
{
    MKTransitionContext *transitionContext = [self new];
    transitionContext->_containerView      = containerView;
    transitionContext->_fromViewController = fromViewController;
    transitionContext->_toViewController   = toViewController;
    return transitionContext;
}

- (UIView *)containerView
{
    return _containerView;
}

- (BOOL)isPresenting
{
    return _toViewController != nil;
}

- (BOOL)isAnimated
{
    return _toViewController
         ? _toViewController.transitioningDelegate != nil
         : _fromViewController.transitioningDelegate != nil;
}

- (BOOL)isInteractive
{
    return NO;
}

- (void)animateTranstion
{
    id<UIViewControllerAnimatedTransitioning> transitionController = self.isPresenting
        ? [_toViewController.transitioningDelegate
           animationControllerForPresentedController:_toViewController
           presentingController:_fromViewController
           sourceController:_fromViewController]
        : [_fromViewController.transitioningDelegate
           animationControllerForDismissedController:_fromViewController];
    
    [transitionController animateTransition:self];
}

- (void)cancel
{
    if (_cancelled == NO)
    {
        _cancelled = YES;
        if (self.isAnimated)
        {
            [CATransaction begin];
            [_containerView.layer removeAllAnimations];
            [CATransaction commit];
        }
        [self completeTransition:NO];
    }
}

- (BOOL)transitionWasCancelled
{
    return _cancelled;
}

- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationNone;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
}

- (void)finishInteractiveTransition
{
}

- (void)cancelInteractiveTransition
{
}

- (void)completeTransition:(BOOL)didComplete
{
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    if ([key isEqualToString:UITransitionContextToViewControllerKey])
        return _toViewController;
    else if ([key isEqualToString:UITransitionContextFromViewControllerKey])
        return _fromViewController;
    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    return vc == _toViewController ? CGRectZero : _fromViewController.view.frame;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    return vc == _toViewController ? _toViewController.view.frame : CGRectZero;
}

@end
