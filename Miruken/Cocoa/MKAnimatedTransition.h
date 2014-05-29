//
//  MKAnimatedTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKTransitionTraits.h"
#import "MKStartingPosition.h"

@interface MKAnimatedTransition : NSObject
    <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, MKTransitionTraits>

@property (readonly,  assign, nonatomic) BOOL           isPresenting;
@property (readwrite, assign, nonatomic) NSTimeInterval animationDuration;

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController;

- (void)completeTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

- (MKStartingPosition)inverseStartingPosition:(MKStartingPosition)position;

@end
