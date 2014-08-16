//
//  CallbackHandler+Resolvers.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Resolvers.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"
#import "MKCallbackErrors.h"
#import "MKTypeOf.h"

@implementation MKCallbackHandler (Resolvers)

- (id)resolve:(id)descriptor
{
    switch ([MKTypeOf id:descriptor]) {
        case MKIdTypeNil:
            return nil;
            
        case MKIdTypeClass:
            return [self getClass:descriptor object:nil];
            
        case MKIdTypeProtocol:
            return [self getProtocol:descriptor];
            
        case MKIdTypeObject:
            return [self getClass:nil object:descriptor];
            
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                        reason:[NSString stringWithFormat:
                                @"Invalid desciptor %@.  Must be a class, protocol or object.",
                                descriptor]
                      userInfo:nil];
    }
}

- (id)objectForKeyedSubscript:(id)descriptor
{
    return [self resolve:descriptor];
}

- (id)getClass:(Class)aClass object:(id)anObject
{
    MKObjectCallbackReceiver *receiver = anObject
                                     ? [MKObjectCallbackReceiver forObject:anObject]
                                     : [MKObjectCallbackReceiver forClass:aClass];
    if ([self handle:receiver])
    {
        id received = receiver.object;
        return (received && (anObject == nil || received != anObject)) ? received : receiver;
    }
    return nil;
}

- (id)getProtocol:(Protocol *)aProtocol
{
    MKProtocolCallbackReceiver *receiver = [MKProtocolCallbackReceiver forProtocol:aProtocol];
    return [self handle:receiver]
         ? (receiver.object ? receiver.object : receiver)
         : nil;
}

@end
