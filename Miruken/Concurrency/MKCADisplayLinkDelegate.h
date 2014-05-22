//
//  MKCADisplayLinkDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate.h"

/**
  Defines the concurrency strategy for executing an invocation bound to the display vsync.
 */

@interface MKCADisplayLinkDelegate : MKAsyncDelegate

+ (instancetype)displayLinkOnRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;

@end
