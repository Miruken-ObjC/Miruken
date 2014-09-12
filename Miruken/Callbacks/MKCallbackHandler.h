//
//  MKCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/17/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  This protocol exposes the core capability to handle callbacks.
  A Callback can be any object and is only interpreted in the context
  of a MKCallbackHandler.  Typically, handling a callback is complete
  after the first MKCallbackHandler handles it.  However, greedy can
  be specified to indicate that all MKCallbackHandlers should get the
  opportunity to handle the callback.
 */

@protocol MKCallbackHandler <NSObject>

- (BOOL)handle:(id)callback;

- (BOOL)handle:(id)callback greedy:(BOOL)greedy;

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer;

@end

@interface MKCallbackHandler : NSObject <MKCallbackHandler>

- (NSMethodSignature *)baseMethodSignatureForSelector:(SEL)aSelector;

+ (BOOL)isUnknownMethod:(NSMethodSignature *)methodSignature;

@end

 