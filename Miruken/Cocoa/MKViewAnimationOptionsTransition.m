//
//  MKViewAnimationTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#define kViewAnimationOptionsTransitionsMask   (7 << 20)

#import "MKViewAnimationOptionsTransition.h"

@implementation MKViewAnimationOptionsTransition
{
    UIViewAnimationOptions _animationOptions;
    BOOL                   _isPresenting;
}

+ (instancetype)transitionWithOptions:(UIViewAnimationOptions)options
{
    MKViewAnimationOptionsTransition *transition = [self new];
    transition->_animationOptions                   = options;
    return transition;
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
    return 0.7f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView           *containerView      = [transitionContext containerView];
    UIViewController *fromViewController =
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (fromViewController.view && toViewController.view)
    {
        [containerView addSubview:fromViewController.view];
        [containerView addSubview:toViewController.view];
        [UIView transitionFromView:fromViewController.view
                            toView:toViewController.view
                          duration:[self transitionDuration:transitionContext]
                           options:_animationOptions
                        completion:^(BOOL finished) {
                            [transitionContext completeTransition:finished];
                        }];
    }
    else
    {
        UIViewAnimationOptions animationOptions;
        if (_isPresenting)
        {
            animationOptions = _animationOptions;
            [containerView addSubview:toViewController.view];
        }
        else
            animationOptions = [self inferInverseAnimationOptions];
        
        if ([self shouldPerformTransitionWithView])
        {
            [UIView transitionWithView:containerView
                              duration:[self transitionDuration:transitionContext]
                               options:animationOptions animations:^{
                                   if (_isPresenting)
                                       [containerView addSubview:toViewController.view];
                                   else
                                       [toViewController.view removeFromSuperview];
                               } completion:^(BOOL finished) {
                                   [transitionContext completeTransition:finished];
                               }];
        }
    }
}

- (UIViewAnimationOptions)inferInverseAnimationOptions
{
    UIViewAnimationOptions options    = (_animationOptions & ~kViewAnimationOptionsTransitionsMask);
    UIViewAnimationOptions transition = (_animationOptions & kViewAnimationOptionsTransitionsMask);
    
    switch (transition)
    {
        case UIViewAnimationOptionTransitionFlipFromTop:
            options |= UIViewAnimationOptionTransitionFlipFromBottom;
      
        case UIViewAnimationOptionTransitionFlipFromBottom:
            options |= UIViewAnimationOptionTransitionFlipFromTop;

        case UIViewAnimationOptionTransitionFlipFromLeft:
            options |= UIViewAnimationOptionTransitionFlipFromRight;
    
        case UIViewAnimationOptionTransitionFlipFromRight:
            options |= UIViewAnimationOptionTransitionFlipFromLeft;

        case UIViewAnimationOptionTransitionCurlDown:
            options |= UIViewAnimationOptionTransitionCurlUp;
            break;
            
        default:
            options = _animationOptions;
            break;
    }
    
    return options;
}

- (BOOL)shouldPerformTransitionWithView
{
    UIViewAnimationOptions transition = (_animationOptions & kViewAnimationOptionsTransitionsMask);
    
    return _isPresenting
         ? transition != UIViewAnimationOptionTransitionCurlUp
         : transition != UIViewAnimationOptionTransitionCurlDown;
}

@end
