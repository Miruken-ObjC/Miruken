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

+ (instancetype)threadedNew;

+ (instancetype)threadedMain;

+ (instancetype)threadedMainWait;

+ (instancetype)threaded:(NSThread *)thread;

+ (instancetype)queued;

+ (instancetype)queued:(NSOperationQueue *)queue;

+ (instancetype)queuedMain;

+ (instancetype)dispatchedMain;

+ (instancetype)dispatchedGlobal;

+ (instancetype)dispatchedGlobal:(long)priority;

+ (instancetype)delayedDispatchedGlobal:(NSTimeInterval)delay;

+ (instancetype)dispatchedQueued:(dispatch_queue_t)queue;

+ (instancetype)delayed:(NSTimeInterval)delay;

+ (instancetype)delayedMain:(NSTimeInterval)delay;

+ (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate;

@end
