//
//  NSObject+Threaded.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+Concurrency.h"
#import "MKAsyncObject.h"
#import "MKNewThreadDelegate.h"
#import "MKMainThreadDelegate.h"
#import "MKThreadDelegate.h"
#import "MKOperationQueueDelegate.h"
#import "MKGrandCentralDispatchDelegate.h"
#import "MKDelayedDelegate.h"
#import "MKScheduledPromise.h"
#import "MKAction.h"

@implementation NSObject (NSObject_Concurrency)

#pragma mark - Threads

+ (instancetype)threadedNew
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKNewThreadDelegate sharedInstance]];
}

+ (instancetype)threadedMain
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKMainThreadDelegate sharedInstance]];
}

+ (instancetype)threadedMainWait
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKMainThreadDelegate sharedInstanceWait]];
}

+ (instancetype)threaded:(NSThread *)thread
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKThreadDelegate onThread:thread]];
}

- (instancetype)inNewThread
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction threadedNew]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKNewThreadDelegate sharedInstance]];
}

- (instancetype)onMainThread
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction threadedMain]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKMainThreadDelegate sharedInstance]];
}

- (instancetype)onMainThreadWait
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction threadedMainWait]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKMainThreadDelegate sharedInstanceWait]];
}

- (instancetype)onThread:(NSThread *)thread
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction threaded:thread]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKThreadDelegate onThread:thread]];
}

#pragma mark - Operation queues

+ (instancetype)queued
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                     delegate:[MKOperationQueueDelegate forObject:self]];
}

+ (instancetype)queued:(NSOperationQueue *)queue
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKOperationQueueDelegate withQueue:queue]];
}

+ (instancetype)queuedMain
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class] delegate:
                [MKOperationQueueDelegate withQueue:[NSOperationQueue mainQueue]]];
}

- (instancetype)queued
{
    return (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKOperationQueueDelegate forObject:self]];
}

- (instancetype)onQueue:(NSOperationQueue *)queue
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction queued:queue]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKOperationQueueDelegate withQueue:queue]];
}

- (instancetype)onMainQueue
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction queuedMain]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:
                [MKOperationQueueDelegate withQueue:[NSOperationQueue mainQueue]]];
}

#pragma mark - Grand Central Dispatch

+ (instancetype)dispatchedMain
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKGrandCentralDispatchDelegate dispatchMainQueue]];
}

+ (instancetype)dispatchedGlobal
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueue]];
}

+ (instancetype)dispatchedGlobal:(long)priority
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueueWithPriority:priority]];
}

+ (instancetype)delayedDispatchedGlobal:(NSTimeInterval)delay
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueueWithDelay:delay]];

}

+ (instancetype)dispatchedQueued:(dispatch_queue_t)queue
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKGrandCentralDispatchDelegate dispatchQueue:queue]];
}

- (instancetype)dispatchGlobal
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction dispatchedGlobal]]
         : (id)[[MKAsyncObject alloc] initWithObject:self
                        delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueue]];
}

- (instancetype)dispatchMain
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction dispatchedMain]]
         : (id)[[MKAsyncObject alloc] initWithObject:self
                                          delegate:[MKGrandCentralDispatchDelegate dispatchMainQueue]];
}

- (instancetype)dispatchGlobal:(long)priority
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction dispatchedGlobal:priority]]
         : (id)[[MKAsyncObject alloc] initWithObject:self
                delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueueWithPriority:priority]];
}

- (instancetype)dispatchGlobalAfterDelay:(NSTimeInterval)delay
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:
                                                                [MKAction delayedDispatchedGlobal:delay]]
         : (id)[[MKAsyncObject alloc] initWithObject:self
                    delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueueWithDelay:delay]];
}

- (instancetype)onDispatchQueue:(dispatch_queue_t)queue
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction dispatchedQueued:queue]]
         : (id)[[MKAsyncObject alloc] initWithObject:self
                                          delegate:[MKGrandCentralDispatchDelegate dispatchQueue:queue]];
}

#pragma mark - Delays

+ (instancetype)delayed:(NSTimeInterval)delay;
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKDelayedDelegate withDelay:delay]];
}

+ (instancetype)delayedMain:(NSTimeInterval)delay
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class]
                                         delegate:[MKDelayedDelegate withDelayOnMain:delay]];
}

- (instancetype)afterDelay:(NSTimeInterval)delay
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction delayed:delay]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKDelayedDelegate withDelay:delay]];
}

- (instancetype)onMainAfterDelay:(NSTimeInterval)delay
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction delayedMain:delay]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKDelayedDelegate withDelayOnMain:delay]];
}

#pragma mark - Custom

+ (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate
{
    return (id)[[MKAsyncObject alloc] initWithClass:[self class] delegate:asyncDelegate];
}

- (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction concurrent:asyncDelegate]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:asyncDelegate];
}

@end
