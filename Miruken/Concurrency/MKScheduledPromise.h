//
//  CNScheduledPromise.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

@class MKAction;

/**
  A trampoline that uses a scheduler to fulfill a Promise using a supplied
  concurrency model.  This is often used when the UI needs to be updated on 
  the main thread.
  */

@interface MKScheduledPromise : NSProxy

+ (id)schedulePromise:(MKPromise)promise schedule:(MKAction *)scheduler;

@end
