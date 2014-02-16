//
//  MKProtocolCallbackReceiver.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKProtocolCallbackReceiver.h"

@implementation MKProtocolCallbackReceiver

@synthesize forProtocol = _protocol;
@synthesize object      = _object;

+ (instancetype)forProtocol:(Protocol *)protocol
{
    MKProtocolCallbackReceiver *receiver = [self new];
    receiver->_protocol                  = protocol;
    return receiver;
}

- (id)resolve:(id)result
{
    if ([result conformsToProtocol:self.forProtocol])
    {
        _object = result;
        [super resolve:_object];
    }
    return self;
}

- (BOOL)tryResolve:(id)result
{
    if ([result conformsToProtocol:self.forProtocol])
    {
        _object = result;
        [self resolve:_object];
        return YES;
    }
    return NO;
}

- (id)reject:(id)reason
{
    [super reject:reason];
    return self;
}

@end
