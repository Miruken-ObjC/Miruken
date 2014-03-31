//
//  MKAnimatedTransitionScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationScope.h"

@interface MKAnimatedTransitionScope : MKPresentationScope

- (instancetype)flipFromLeft;

- (instancetype)flipFromRight;

- (instancetype)curlUp;

- (instancetype)curlDown;

- (instancetype)crossDissolve;

- (instancetype)flipFromTop;

- (instancetype)flipFromBottom;

- (instancetype)duration:(NSTimeInterval)duration;

@end
