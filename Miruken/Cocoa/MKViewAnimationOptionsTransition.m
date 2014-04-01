//
//  MKViewAnimationTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#define kDefaultAnimationDuration              (0.7f)
#define kViewAnimationOptionsTransitionsMask   (7 << 20)

#import "MKViewAnimationOptionsTransition.h"

@implementation MKViewAnimationOptionsTransition
{
    BOOL                    _isPresenting;
    UIViewAnimationOptions  _animationOptions;
}

+ (instancetype)transitionWithOptions:(UIViewAnimationOptions)options
{
    MKViewAnimationOptionsTransition *transition = [self new];
    transition->_animationOptions                = options;
    transition->_animationDuration               = kDefaultAnimationDuration;
    transition->_edgeInsets                      = UIEdgeInsetsZero;
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
    return _animationDuration;
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
        UIViewAnimationOptions animationOptions
                             = _isPresenting
                             ? _animationOptions
                             : [self inferInverseAnimationOptions];
        
        if ([self shouldPerformTransitionWithOptions:animationOptions])
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
            break;
            
        case UIViewAnimationOptionTransitionFlipFromBottom:
            options |= UIViewAnimationOptionTransitionFlipFromTop;
            break;
            
        case UIViewAnimationOptionTransitionFlipFromLeft:
            options |= UIViewAnimationOptionTransitionFlipFromRight;
            break;
            
        case UIViewAnimationOptionTransitionFlipFromRight:
            options |= UIViewAnimationOptionTransitionFlipFromLeft;
            break;
            
        case UIViewAnimationOptionTransitionCurlDown:
            options |= UIViewAnimationOptionTransitionCurlUp;
            break;
            
        default:
            options = _animationOptions;
            break;
    }
    
    return options;
}

- (BOOL)shouldPerformTransitionWithOptions:(UIViewAnimationOptions)options
{
    UIViewAnimationOptions transition = (options & kViewAnimationOptionsTransitionsMask);
    
    return _isPresenting
         ? transition != UIViewAnimationOptionTransitionCurlUp
         : transition != UIViewAnimationOptionTransitionCurlDown;
}

@end
