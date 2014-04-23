//
//  MKFlipTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/21/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by by Frédéric ADDA on 07/12/2013.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "MKFlipTransition.h"

@implementation MKFlipTransition


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;

}

@end
