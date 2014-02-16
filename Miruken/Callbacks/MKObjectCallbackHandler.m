//
//  MKObjectCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/8/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKObjectCallbackHandler.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"

@implementation MKObjectCallbackHandler
{
    id    _object;
    BOOL  _kindOfObject;
}

+ (instancetype)withObject:(id)anObject
{
    return [self withObject:anObject isKindOf:NO];
}

+ (instancetype)withObject:(id)anObject isKindOf:(BOOL)isKindOf;
{
    MKObjectCallbackHandler *handler = [self new];
    handler->_object                 = anObject;
    handler->_kindOfObject           = isKindOf;
    return handler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:[MKObjectCallbackReceiver class]])
    {
        MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
        return [receiver tryResolve:_object withKindOfClass:_kindOfObject];
    }
    
    if ([callback isKindOfClass:[MKProtocolCallbackReceiver class]])
    {
        MKProtocolCallbackReceiver *receiver = (MKProtocolCallbackReceiver *)callback;
        return [receiver tryResolve:_object];
    }
    
    return NO;
}

- (void)dealloc
{
    _object = nil;
}

@end
