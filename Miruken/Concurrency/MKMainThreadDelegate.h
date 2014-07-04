//
//  CNMainThreadDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/24/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate_Subclassing.h"

/**
  Defines the concurrency strategy for executing an invocation on the main thread.
  This strategy is preferrable when interacting with the User Interface.
 */

@interface MKMainThreadDelegate : MKAsyncDelegate

+ (instancetype)sharedInstance;

+ (instancetype)sharedInstanceWait;

@end
