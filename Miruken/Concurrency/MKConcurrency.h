//
//  MKConcurrency.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/7/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAction.h"

@protocol MKAsyncDelegate;

/**
  Identifies the concurrency options available to objects.  Any object invocation
  can be performed on one of these concurrency models.  In addition, these models
  can be chained together to provide more complex execution plans.
 */

@protocol MKConcurrency <NSObject>

@optional
#pragma mark - Threads

- (instancetype)inNewThread;

- (instancetype)onMainThread;

- (instancetype)onMainThreadWait;

- (instancetype)onThread:(NSThread *)thread;

#pragma mark - Operation Queues

- (instancetype)queued;

- (instancetype)onQueue:(NSOperationQueue *)queue;

- (instancetype)onMainQueue;

#pragma mark - Grand Central Dispatch

- (instancetype)dispatchMain;

- (instancetype)dispatchGlobal;

- (instancetype)dispatchGlobal:(long)priority;

- (instancetype)onDispatchQueue:(dispatch_queue_t)queue;

- (instancetype)onBarrierQueue:(dispatch_queue_t)queue;

#pragma mark - Delays & Timers

- (instancetype)afterDelay:(NSTimeInterval)delay;

- (instancetype)onMainAfterDelay:(NSTimeInterval)delay;

- (instancetype)dispatchGlobalAfterDelay:(NSTimeInterval)delay;

- (instancetype)atInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                    leeway:(NSTimeInterval)leeway;

- (instancetype)atInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                    leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue;

- (instancetype)onMainAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                          leeway:(NSTimeInterval)leeway;

#pragma mark - Custom Strategy

- (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate;

@end

