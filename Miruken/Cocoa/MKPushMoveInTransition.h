//
//  MKPushMoveInTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransition.h"
#import "MKStartingPosition.h"
#import "MKTransitionOptions.h"

@interface MKPushMoveInTransition : MKAnimatedTransition

@property (assign, nonatomic) MKTransitionFadeStyle fadeStyle;

+ (instancetype)pushFromPosition:(MKStartingPosition)position;

+ (instancetype)moveInFromPosition:(MKStartingPosition)position;

@end
