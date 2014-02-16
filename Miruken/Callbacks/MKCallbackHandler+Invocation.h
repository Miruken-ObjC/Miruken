//
//  CallbackHandler+Invocation.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKHandleMethod.h"

// This category enables communication to callback handlers using normal
// objective-c calling conventions rather than the generic handle callback.

typedef NS_ENUM(NSUInteger, MKCallbackHandlerCallOptions) {
    MKCallbackHandlerCallOptionsNone       = 0,
    MKCallbackHandlerCallOptionsBroadcast  = 1 << 0,
    MKCallbackHandlerCallOptionsBestEffort = 1 << 1
};

@interface MKCallbackHandler (MKCallbackHandler_Invovation)

- (instancetype)broadcast;

- (instancetype)bestEffort;

- (instancetype)notify;

- (instancetype)withCallOptions:(MKCallbackHandlerCallOptions)options;

- (instancetype)withCallInvokeBlock:(MKHandleMethodBlock)didInvoke;

- (instancetype)withCallOptions:(MKCallbackHandlerCallOptions)options didInvoke:(MKHandleMethodBlock)didInvoke;

@end
