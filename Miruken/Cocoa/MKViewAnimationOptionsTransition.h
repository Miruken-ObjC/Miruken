//
//  MKViewAnimationOptionsTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKViewAnimationOptionsTransition : NSObject
 <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) UIEdgeInsets   edgeInsets;

+ (instancetype)transitionWithOptions:(UIViewAnimationOptions)options;

@end
