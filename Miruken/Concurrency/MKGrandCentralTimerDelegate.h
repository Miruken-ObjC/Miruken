//
//  MKGrandCentralTimerDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate_Subclassing.h"

/**
  Defines the concurrency strategy for executing an invocation at repeating intervals using GCD.
 */

@interface MKGrandCentralTimerDelegate : MKAsyncDelegate

+ (instancetype)scheduleAfterDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval
                            leeway:(NSTimeInterval)leeway;

+ (instancetype)scheduleAfterDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval
                            leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue;

+ (instancetype)scheduleOnMainAfterDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval
                                  leeway:(NSTimeInterval)leeway;


@end
