//
//  MKAnimatedTransitionScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationScope.h"
#import "MKStartingPosition.h"

@interface MKAnimatedTransitionScope : MKPresentationScope

- (instancetype)flipFromLeft;

- (instancetype)flipFromRight;

- (instancetype)curlUp;

- (instancetype)curlDown;

- (instancetype)crossDissolve;

- (instancetype)flipFromTop;

- (instancetype)flipFromBottom;

- (instancetype)pushFromTop;

- (instancetype)pushFromBottom;

- (instancetype)pushFromLeft;

- (instancetype)pushFromRight;

- (instancetype)pushFromTopLeft;

- (instancetype)pushFromTopRight;

- (instancetype)pushFromBottomLeft;

- (instancetype)pushFromBottomRight;

- (instancetype)pushFrom:(MKStartingPosition)position;

- (instancetype)animationOptions:(UIViewAnimationOptions)options;

- (instancetype)duration:(NSTimeInterval)duration;

@end
