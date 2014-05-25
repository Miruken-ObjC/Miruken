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
#import "MKDelayedDelegate.h"
#import "MKOperationQueueDelegate.h"
#import "MKGrandCentralDispatchDelegate.h"
#import "MKGrandCentralTimerDelegate.h"
#import "MKCADisplayLinkDelegate.h"
#import "MKScheduledPromise.h"
#import "MKAction.h"

@implementation NSObject (NSObject_Concurrency)

#pragma mark - Threads

+ (instancetype)threadedNew
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                                           delegate:[MKNewThreadDelegate sharedInstance]];
}

+ (instancetype)threadedMain
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                                           delegate:[MKMainThreadDelegate sharedInstance]];
}

+ (instancetype)threadedMainWait
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                                           delegate:[MKMainThreadDelegate sharedInstanceWait]];
}

+ (instancetype)threaded:(NSThread *)thread
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
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
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKOperationQueueDelegate forObject:self]];
}

+ (instancetype)queued:(NSOperationQueue *)queue
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKOperationQueueDelegate withQueue:queue]];
}

+ (instancetype)queuedMain
{
    return (id)[[MKAsyncObject alloc] initWithClass:self delegate:
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
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralDispatchDelegate dispatchMainQueue]];
}

+ (instancetype)dispatchedGlobal
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueue]];
}

+ (instancetype)dispatchedGlobal:(long)priority
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueueWithPriority:priority]];
}

+ (instancetype)dispatchedQueued:(dispatch_queue_t)queue
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralDispatchDelegate dispatchQueue:queue]];
}

+ (instancetype)barrierQueued:(dispatch_queue_t)queue
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralDispatchDelegate barrierQueue:queue]];
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

- (instancetype)onBarrierQueue:(dispatch_queue_t)queue
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction dispatchedQueued:queue]]
         : (id)[[MKAsyncObject alloc] initWithObject:self
                delegate:[MKGrandCentralDispatchDelegate barrierQueue:queue]];
}

#pragma mark - Delays & Timers

+ (instancetype)delayed:(NSTimeInterval)delay;
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKDelayedDelegate withDelay:delay]];
}

+ (instancetype)delayedMain:(NSTimeInterval)delay
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKDelayedDelegate withDelayOnMain:delay]];
}

+ (instancetype)delayedDispatchedGlobal:(NSTimeInterval)delay
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
            delegate:[MKGrandCentralDispatchDelegate dispatchGlobalQueueWithDelay:delay]];
    
}

+ (instancetype)scheduledAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                             leeway:(NSTimeInterval)leeway
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralTimerDelegate scheduleAfterDelay:delay interval:interval
                                                                  leeway:leeway]];
}

+ (instancetype)scheduledAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                             leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralTimerDelegate scheduleAfterDelay:delay interval:interval
                                                                  leeway:leeway queue:queue]];
}

+ (instancetype)scheduledOnMainAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                                   leeway:(NSTimeInterval)leeway
{
    return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKGrandCentralTimerDelegate scheduleOnMainAfterDelay:delay interval:interval
                                                                        leeway:leeway]];
}

+ (instancetype)displayLinked
{
    return (id)[[MKAsyncObject alloc] initWithClass:self delegate:[MKCADisplayLinkDelegate new]];
}

+ (instancetype)displayLinkdeOnRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
     return (id)[[MKAsyncObject alloc] initWithClass:self
                delegate:[MKCADisplayLinkDelegate displayLinkdeOnRunLoop:runLoop forMode:mode]];
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

- (instancetype)atInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                    leeway:(NSTimeInterval)leeway
{
    return (id)[[MKAsyncObject alloc] initWithObject:self
                delegate:[MKGrandCentralTimerDelegate scheduleAfterDelay:delay interval:interval
                                                                  leeway:leeway]];
}

- (instancetype)atInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                    leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue
{
    return (id)[[MKAsyncObject alloc] initWithObject:self
                delegate:[MKGrandCentralTimerDelegate scheduleAfterDelay:delay interval:interval
                                                                  leeway:leeway queue:queue]];
}

- (instancetype)onMainAtInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay
                          leeway:(NSTimeInterval)leeway
{
    return (id)[[MKAsyncObject alloc] initWithObject:self
                delegate:[MKGrandCentralTimerDelegate scheduleOnMainAfterDelay:delay interval:interval
                                                                        leeway:leeway]];
}

- (instancetype)displayLink
{
    return (id)[[MKAsyncObject alloc] initWithObject:self delegate:[MKCADisplayLinkDelegate new]];
}

- (instancetype)displayLinkOnRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
    return (id)[[MKAsyncObject alloc] initWithObject:self
                delegate:[MKCADisplayLinkDelegate displayLinkdeOnRunLoop:runLoop forMode:mode]];
}

#pragma mark - Custom Strategy

+ (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate
{
    return (id)[[MKAsyncObject alloc] initWithClass:self delegate:asyncDelegate];
}

- (instancetype)concurrent:(id<MKAsyncDelegate>)asyncDelegate
{
    return [self conformsToProtocol:@protocol(MKPromise)]
         ? [MKScheduledPromise schedulePromise:(id<MKPromise>)self schedule:[MKAction concurrent:asyncDelegate]]
         : (id)[[MKAsyncObject alloc] initWithObject:self delegate:asyncDelegate];
}

@end
