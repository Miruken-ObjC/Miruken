//
//  MKTransitionContext.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/5/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDeferred.h"

@interface MKTransitionContext : MKDeferred <UIViewControllerContextTransitioning>

@property (readonly, nonatomic) UIViewController *fromViewController;
@property (readonly, nonatomic) UIViewController *toViewController;

+ (instancetype)transitionContainerView:(UIView *)containerView
                     fromViewController:(UIViewController *)fromViewController
                       toViewController:(UIViewController *)toViewController;

- (BOOL)isPresenting;

- (void)animateTranstion;

@end
