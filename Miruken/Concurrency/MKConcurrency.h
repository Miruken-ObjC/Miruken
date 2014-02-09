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
- (instancetype)inNewThread;

- (instancetype)onMainThread;

- (instancetype)onMainThreadWait;

- (instancetype)onThread:(NSThread *)thread;

- (instancetype)queued;

- (instancetype)onQueue:(NSOperationQueue *)queue;

- (instancetype)onMainQueue;

- (instancetype)dispatchMain;

- (instancetype)dispatchGlobal;

- (instancetype)dispatchGlobal:(long)priority;

- (instancetype)dispatchGlobalAfterDelay:(NSTimeInterval)delay;

- (instancetype)onDispatchQueue:(dispatch_queue_t)queue;

- (instancetype)afterDelay:(NSTimeInterval)delay;

- (instancetype)onMainAfterDelay:(NSTimeInterval)delay;

- (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate;

@end

