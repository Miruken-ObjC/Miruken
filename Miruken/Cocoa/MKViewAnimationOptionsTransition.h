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

+ (instancetype)transitionWithOptions:(UIViewAnimationOptions)options;

@end
