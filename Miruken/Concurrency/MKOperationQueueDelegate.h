//
//  MKOperationQueueDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/29/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate.h"

/**
  Defines the concurrency strategy for executing an invocation on an
  NSOperationQueue.  This strategy is preferred over new thread creation
  since it provides more fine-grained control and is more intelligent
  mapping operations to threads.
 */

@interface MKOperationQueueDelegate : MKAsyncDelegate

+ (instancetype)withQueue:(NSOperationQueue *)queue;

+ (instancetype)forObject:(id)object;

@end
