//
//  MKBufferedPromise.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/8/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKPromise.h"

/**
  A BufferedPromise adds buffering capability to a promise such that all callbacks
  are buffered until the promise is flushed.  Once flushed, all callbacks execute
  immediately.
  */

@protocol MKBufferedPromise <MKPromise>

- (instancetype)bufferDone:(MKDoneCallback)done;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)bufferDone:(id)when:(MKDoneCallback)done;
#pragma clang diagnostic pop

- (instancetype)bufferFail:(MKFailCallback)fail;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)bufferFail:(id)when:(MKFailCallback)fail;
#pragma clang diagnostic pop

- (instancetype)bufferError:(MKErrorCallback)error;

- (instancetype)bufferException:(MKExceptionCallback)exception;

- (instancetype)bufferCancel:(MKCancelCallback)cancel;

- (instancetype)bufferProgress:(MKProgressCallback)progress;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)bufferProgress:(id)when:(MKProgressCallback)progress;
#pragma clang diagnostic pop

- (instancetype)bufferAlways:(MKAlwaysCallback)always;

- (void)flush;

@end

@interface MKBufferedPromise : NSObject <MKBufferedPromise>

+ (instancetype)bufferPromise:(id<MKPromise>)promise;

- (id)initWithPromise:(id<MKPromise>)promise;

@end
