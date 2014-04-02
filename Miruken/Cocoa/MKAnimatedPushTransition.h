//
//  MKAnimatedPushTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransition.h"
#import "MKTransitionDirection.h"

@interface MKAnimatedPushTransition : MKAnimatedTransition

+ (instancetype)pushDirection:(MKTransitionDirection)direction;

@end
