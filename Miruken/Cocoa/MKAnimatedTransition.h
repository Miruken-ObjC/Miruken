//
//  MKAnimatedTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKStartingPosition.h"
#import "MKTransitionOptions.h"

@interface MKAnimatedTransition : NSObject
    <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (readonly,  assign, nonatomic) BOOL           isPresenting;
@property (readwrite, assign, nonatomic) NSTimeInterval animationDuration;
@property (readwrite, assign, nonatomic) BOOL           clipToBounds;

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController;

- (void)completeTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

- (CGFloat)randomFloatBetween:(float)smallNumber and:(float)bigNumber;

- (void)fade:(MKTransitionFadeStyle)fadeStyle fromView:(UIView *)fromView toView:(UIView *)toView
     initial:(BOOL)initial;

- (MKTransitionFadeStyle)inverseFadeStyle:(MKTransitionFadeStyle)fadeStyle;

- (MKStartingPosition)inverseStartingPosition:(MKStartingPosition)position;

@end
