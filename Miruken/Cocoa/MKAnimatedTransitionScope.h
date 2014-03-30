//
//  MKAnimatedTransitionScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"
#import "MKPresentationPolicy.h"

@interface MKAnimatedTransitionScope : MKCallbackHandlerDecorator

+ (instancetype)for:(MKCallbackHandler *)handler;

- (instancetype)flipFromLeft;

- (instancetype)flipFromRight;

- (instancetype)curlUp;

- (instancetype)curlDown;

- (instancetype)crossDissolve;

- (instancetype)flipFromTop;

- (instancetype)flipFromBottom;

@end
