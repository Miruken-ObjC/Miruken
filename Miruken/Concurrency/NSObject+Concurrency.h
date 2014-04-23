//
//  NSObject+Threaded.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAsyncObject.h"
#import "MKConcurrency.h"

/**
  NSObject category to enable any invocation to be performed concurrently.
  */

@interface NSObject (NSObject_Concurrency) <MKConcurrency>

#pragma mark - Threads

+ (instancetype)threadedNew;

+ (instancetype)threadedMain;

+ (instancetype)threadedMainWait;

+ (instancetype)threaded:(NSThread *)thread;

#pragma mark - Operation Queues

+ (instancetype)queued;

+ (instancetype)queued:(NSOperationQueue *)queue;

+ (instancetype)queuedMain;

#pragma mark - Grand Central Dispatch

+ (instancetype)dispatchedMain;

+ (instancetype)dispatchedGlobal;

+ (instancetype)dispatchedGlobal:(long)priority;

+ (instancetype)dispatchedQueued:(dispatch_queue_t)queue;

+ (instancetype)barrierQueued:(dispatch_queue_t)queue;

#pragma mark - Delays & Timers

+ (instancetype)delayed:(NSTimeInterval)delay;

+ (instancetype)delayedMain:(NSTimeInterval)delay;

+ (instancetype)delayedDispatchedGlobal:(NSTimeInterval)delay;

+ (instancetype)scheduledAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                             leeway:(NSTimeInterval)leeway;

+ (instancetype)scheduledAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                             leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue;

+ (instancetype)scheduledOnMainAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                                   leeway:(NSTimeInterval)leeway;

#pragma mark - Custom Strategy

+ (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate;

@end
