//
//  MKNewThreadDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/24/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate_Subclassing.h"

/**
  Defines the concurrency strategy for executing an invocation in a new thread.
 */

@interface MKNewThreadDelegate : MKAsyncDelegate

+ (instancetype)sharedInstance;

@end
