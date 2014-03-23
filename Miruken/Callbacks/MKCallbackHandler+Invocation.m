//
//  CallbackHandler+Invocation.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Invocation.h"
#import "MKInvocationCallbackHandler.h"

@implementation MKCallbackHandler (Invovation)

- (instancetype)broadcast
{
    return [[MKInvocationCallbackHandler alloc] initOptions:MKCallbackHandlerCallOptionsBroadcast
                                                    handler:self didInvoke:nil];
}

- (instancetype)bestEffort
{
    return [[MKInvocationCallbackHandler alloc] initOptions:MKCallbackHandlerCallOptionsBestEffort
                                                    handler:self didInvoke:nil];
}

- (instancetype)notify
{
    return [[MKInvocationCallbackHandler alloc] initOptions:MKCallbackHandlerCallOptionsBestEffort
                                                          | MKCallbackHandlerCallOptionsBroadcast
                                                    handler:self didInvoke:nil];
}

- (instancetype)withCallOptions:(MKCallbackHandlerCallOptions)options
{
    return [[MKInvocationCallbackHandler alloc] initOptions:options handler:self didInvoke:nil];
}

- (instancetype)withCallInvokeBlock:(MKHandleMethodBlock)didInvoke
{
    return [[MKInvocationCallbackHandler alloc] initOptions:MKCallbackHandlerCallOptionsNone
                                                    handler:self didInvoke:didInvoke];
}

- (instancetype)withCallOptions:(MKCallbackHandlerCallOptions)options didInvoke:(MKHandleMethodBlock)didInvoke
{
    return [[MKInvocationCallbackHandler alloc] initOptions:options handler:self didInvoke:didInvoke];
}

@end
