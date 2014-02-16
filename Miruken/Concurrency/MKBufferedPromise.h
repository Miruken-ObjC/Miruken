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

- (instancetype)bufferDone:(DoneCallback)done;

- (instancetype)bufferFail:(FailCallback)fail;

- (instancetype)bufferError:(ErrorCallback)error;

- (instancetype)bufferException:(ExceptionCallback)exception;

- (instancetype)bufferCancel:(CancelCallback)cancel;

- (instancetype)bufferProgress:(ProgressCallback)progress;

- (instancetype)bufferAlways:(AlwaysCallback)always;

- (void)flush;

@end

@interface MKBufferedPromise : NSObject <MKBufferedPromise>

+ (instancetype)bufferPromise:(id<MKPromise>)promise;

- (id)initWithPromise:(id<MKPromise>)promise;

@end
