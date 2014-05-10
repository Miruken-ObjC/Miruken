//
//  MKCubeTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Andrés Brun on 27/10/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "MKAnimatedTransition.h"

typedef NS_ENUM(NSInteger, MKCubeTransitionAxis) {
    MKCubeTransitionAxisHorizontal = 0,
    MKCubeTransitionAxisVertical
};

@interface MKCubeTransition : MKAnimatedTransition

@property (assign, nonatomic) MKCubeTransitionAxis cubeAxis;
@property (assign, nonatomic) CGFloat              rotateDegrees;
@property (assign, nonatomic) CGFloat              perspective;

+ (instancetype)cubeAxis:(MKCubeTransitionAxis)cubeAxis;

+ (instancetype)cubeAxis:(MKCubeTransitionAxis)cubeAxis rotateDegrees:(CGFloat)rotateDegrees;

@end
