//
//  MKPromise.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKConcurrency.h"

@class  MKPromiseBase;
typedef MKPromiseBase* MKPromise;

typedef void (^MKDoneCallback)(id result);
typedef void (^MKFailCallback)(id reason, BOOL *handled);
typedef void (^MKErrorCallback)(NSError *error, BOOL *handled);
typedef void (^MKExceptionCallback)(NSException *exception, BOOL *handled);
typedef void (^MKProgressCallback)(id progress, BOOL queued);
typedef void (^MKCancelCallback)();
typedef void (^MKAlwaysCallback)();

typedef id   (^MKDoneFilter)(id result);
typedef id   (^MKFailFilter)(id reason);
typedef id   (^MKProgressFilter)(id progress, BOOL *queued);

typedef NS_ENUM(NSUInteger, MKPromiseState) {
    MKPromiseStatePending = 0,
    MKPromiseStateResolved,
    MKPromiseStateRejected,
    MKPromiseStateCancelled
};

/**
  A Promise represents the result of a computation.  It is based on the continuation
  model of programming and supports both synchronous and asynchronous computations.
  Promises support pipes which can be used to project the results of a computation or
  chain multiple computations together to model more complex workflows.
  */

@protocol MKPromise

@property (readonly) MKPromiseState state;

- (instancetype)done:(MKDoneCallback)done;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)done:(id)when:(MKDoneCallback)done;
#pragma clang diagnostic pop

- (instancetype)fail:(MKFailCallback)fail;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)fail:(id)when:(MKFailCallback)fail;
#pragma clang diagnostic pop

- (instancetype)error:(MKErrorCallback)error;

- (instancetype)exception:(MKExceptionCallback)exception;

- (instancetype)cancel:(MKCancelCallback)cancel;

- (instancetype)always:(MKAlwaysCallback)always;

- (instancetype)progress:(MKProgressCallback)progress;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)progress:(id)when:(MKProgressCallback)progress;
#pragma clang diagnostic pop

- (MKPromise)then:(MKDoneFilter)doneFilter;

- (MKPromise)then:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter;

- (MKPromise)then:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
   progressFilter:(MKProgressFilter)progressFilter;

- (instancetype)await;

- (BOOL)waitTimeInterval:(NSTimeInterval)timeInterval;

- (BOOL)waitUntilDate:(NSDate *)date;

- (void)wait;

- (void)cancel;

@end

@interface MKPromiseBase : NSObject <MKPromise>
@end
