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
}

+ (instancetype)transitionContainerView:(UIView *)containerView
                     fromViewController:(UIViewController *)fromViewController
                       toViewController:(UIViewController *)toViewController
{
    MKTransitionContext *transitionContext    = [self new];
    transitionContext->_containerView         = containerView;
    transitionContext->_fromViewController    = fromViewController;
    transitionContext->_toViewController      = toViewController;
    return transitionContext;
}

- (UIView *)containerView
{
    return _containerView;
}

- (BOOL)isAnimated
{
    return YES;
}

- (BOOL)isInteractive
{
    return NO;
}

- (BOOL)transitionWasCancelled
{
    return NO;
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
