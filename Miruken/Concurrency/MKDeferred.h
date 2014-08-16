//
//  MKDeferred.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKPromise.h"

/**
  Represents a computation that may or may not be completed asynchronously.
  A Deferred object is either "pending", "resolved", or "rejected".  Typically,
  Deferred objects are not returned to callers, but rather a "MKPromise" to them
  so that only the owner can control the state of the computation.
 */

@interface MKDeferred : NSObject <MKPromise>

+ (instancetype)resolved;

+ (instancetype)resolved:(id)result;

+ (instancetype)rejected:(id)reason;

- (MKPromise)promise;

- (instancetype)done:(MKDoneCallback)done;

- (instancetype)fail:(MKFailCallback)fail;

- (instancetype)error:(MKErrorCallback)error;

- (instancetype)exception:(MKExceptionCallback)exception;

- (instancetype)always:(MKAlwaysCallback)always;

- (instancetype)resolve;

- (instancetype)resolve:(id)result;

- (instancetype)reject:(id)reason;

- (instancetype)notify:(id)progress;

- (instancetype)notify:(id)progress queue:(BOOL)queue;

- (instancetype)connectPromise:(MKPromise)promise;

+ (MKPromise)when:(id)condition;

+ (MKPromise)whenAll:(NSArray *)conditions;

@end
