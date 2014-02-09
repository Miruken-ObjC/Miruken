//
//  MKDelayedDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/25/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate.h"

/**
  Defines the concurrency strategy for executing an invocation after a delay.
 */

@interface MKDelayedDelegate : MKAsyncDelegate

+ (instancetype)withDelay:(NSTimeInterval)delay;

+ (instancetype)withDelayOnMain:(NSTimeInterval)delay;

@end
