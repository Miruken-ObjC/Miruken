//
//  MKNatGeoTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/24/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransition.h"

@interface MKNatGeoTransition : MKAnimatedTransition

@property (assign, nonatomic) CGFloat perspective;

+ (instancetype)natGeoFirstPartRatio:(CGFloat)firstPartRatio;

@end
