//
//  MKThreadDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/27/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate_Subclassing.h"

/**
 Defines the concurrency strategy for executing an invocation in an abritrary thread.
 */

@interface MKThreadDelegate : MKAsyncDelegate

+ (instancetype)onThread:(NSThread *)thread;

@end
