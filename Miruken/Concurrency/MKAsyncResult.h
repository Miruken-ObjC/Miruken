//
//  MKAsyncResult.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

/**
  Identifies the contract for all asynchronous operations.
  Acessing the value of an AsyncResult will block until the result is available.
 */

@protocol MKAsyncResult <NSObject>

- (BOOL)isComplete;

- (id)result;

- (void)complete;

- (void)repeat;

- (MKPromise)promise;

@end
