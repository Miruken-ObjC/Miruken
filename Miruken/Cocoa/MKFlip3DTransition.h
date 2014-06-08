//
//  MKFlip3DTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by by Frédéric ADDA on 07/12/2013.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "MKAnimatedTransition.h"

@interface MKFlip3DTransition : MKAnimatedTransition

@property (assign, nonatomic) CGFloat perspective;
@property (assign, nonatomic) BOOL    clipToBounds;

+ (instancetype)turnFromPosition:(MKStartingPosition)position;

@end
