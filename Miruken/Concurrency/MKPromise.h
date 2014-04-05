//
//  MKPromise.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKConcurrency.h"

@protocol MKBufferedPromise;

typedef void (^DoneCallback)(id result);
typedef void (^FailCallback)(id reason, BOOL *handled);
typedef void (^ErrorCallback)(NSError *error, BOOL *handled);
typedef void (^ExceptionCallback)(NSException *exception, BOOL *handled);
typedef void (^ProgressCallback)(id progress, BOOL queued);
typedef void (^CancelCallback)();
typedef void (^AlwaysCallback)();

typedef id   (^DoneFilter)(id result);
typedef id   (^FailFilter)(id reason);
typedef id   (^ProgressFilter)(id progress, BOOL *queued);

typedef NS_ENUM(NSUInteger, DeferredState) {
    DeferredStatePending = 0,
    DeferredStateResolved,
    DeferredStateRejected,
    DeferredStateCancelled
};

/**
  A Promise represents the result of a computation.  It is based on the continuation
  model of programming and supports both synchronous and asynchronous computations.
  Promises support pipes which can be used to project the results of a computation or
  chain multiple computations together to model more complex workflows.
  */

@protocol MKPromise <MKConcurrency>

@property (readonly) DeferredState state;

- (BOOL)isPending;

- (BOOL)isResolved;

- (BOOL)isRejected;

- (BOOL)isCancelled;

- (instancetype)done:(DoneCallback)done;

- (instancetype)fail:(FailCallback)fail;

- (instancetype)error:(ErrorCallback)error;

- (instancetype)exception:(ExceptionCallback)exception;

- (instancetype)cancel:(CancelCallback)cancel;

- (instancetype)always:(AlwaysCallback)always;

- (instancetype)progress:(ProgressCallback)progress;

- (instancetype)then:(NSArray *)done fail:(NSArray *)fail;

- (instancetype)then:(NSArray *)done fail:(NSArray *)fail progress:(NSArray *)progress;

- (id<MKPromise>)pipe:(DoneFilter)doneFilter;

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter;

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
     progressFilter:(ProgressFilter)progressFilter;

- (id<MKBufferedPromise>)buffer;

- (BOOL)waitTimeInterval:(NSTimeInterval)timeInterval;

- (BOOL)waitUntilDate:(NSDate *)date;

- (void)wait;

- (void)cancel;

@end
