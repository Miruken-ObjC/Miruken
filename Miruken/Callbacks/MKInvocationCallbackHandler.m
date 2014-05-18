//
//  MKInvocationCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKInvocationCallbackHandler.h"

@implementation MKInvocationCallbackHandler
{
    MKCallbackHandlerCallOptions  _options;
    MKHandleMethodBlock           _didInvoke;
}

- (id)initOptions:(MKCallbackHandlerCallOptions)options handler:(MKCallbackHandler *)handler
        didInvoke:(MKHandleMethodBlock)didInvoke
{
    if (self = [super initWithDecoratee:handler])
    {
        _options   = options;
        _didInvoke = didInvoke;
    }
    return self;
}

- (BOOL)dispatchInvocation:(NSInvocation*)anInvocation
{
    BOOL broadcast  = _options & MKCallbackHandlerCallOptionsBroadcast;
    BOOL bestEffort = _options & MKCallbackHandlerCallOptionsBestEffort;
    
    if (bestEffort && [MKCallbackHandler isUnknownMethod:anInvocation.methodSignature])
        return YES;
    
    MKHandleMethod *invokeMethod = [MKHandleMethod withInvocation:anInvocation didInvoke:_didInvoke];
    return [super handle:invokeMethod greedy:broadcast composition:self.decoratee] || bestEffort;
}

@end
