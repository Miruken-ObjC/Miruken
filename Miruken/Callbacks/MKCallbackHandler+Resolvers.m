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

@implementation MKCallbackHandler (Resolvers)

#pragma mark - Callback class support

- (id)getClass:(Class)aClass orDefault:(id)theDefault
{
    if (theDefault != nil && [theDefault isKindOfClass:aClass] == NO)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:
                                               @"The default value is not a kind of class %@", aClass]
                                     userInfo:nil];
    }
    MKObjectCallbackReceiver *receiver = [MKObjectCallbackReceiver forClass:aClass];
    BOOL handled                       = [self handle:receiver];
    return handled ? receiver.object : theDefault;
}

- (BOOL)tryGetClass:(Class)aClass into:(out id __strong *)outItem
{
    MKObjectCallbackReceiver *receiver = [MKObjectCallbackReceiver forClass:aClass];
    BOOL handled                       = [self handle:receiver];
    *outItem                           = receiver.object;
    return handled;    
}

- (id<MKPromise>)getClassDeferred:(Class)aClass
{
    MKObjectCallbackReceiver *receiver = [MKObjectCallbackReceiver forClass:aClass];
    if ([self handle:receiver] == NO)
    {
        NSDictionary* userInfo = @{ NSLocalizedDescriptionKey :
            [NSString stringWithFormat:@"Callback class %@ could not be resolved", aClass]
        };
        
        NSError *error = [NSError errorWithDomain:MKCallbackErrorDomain
                                             code:MKCallbackErrorCallbackClassNotFound
                                         userInfo:userInfo];
        [receiver reject:error];
    }
    return receiver;
}

- (id<MKPromise>)handleDeferred:(id)callback
{
    MKObjectCallbackReceiver *receiver = [MKObjectCallbackReceiver forObject:callback];
    if ([self handle:receiver] == NO)
    {
        NSDictionary* userInfo = @{ NSLocalizedDescriptionKey :
            [NSString stringWithFormat:@"Callback %@ could not be handled", callback]
        };

        NSError *error = [NSError errorWithDomain:MKCallbackErrorDomain
                                             code:MKCallbackErrorCallbackNotHandled
                                         userInfo:userInfo];
        [receiver reject:error];
    }
    return receiver;
}

#pragma mark - Callback protocol support

- (id)getProtocol:(Protocol *)aProtocol orDefault:(id)theDefault
{
    if (theDefault != nil && [theDefault conformsToProtocol:aProtocol] == NO)
    {
        @throw [NSException 
                exceptionWithName: NSInvalidArgumentException
                reason: [NSString stringWithFormat:@"The default value does not conform to protocol %@", 
                         NSStringFromProtocol(aProtocol)]
                userInfo: nil];         
    }
    MKProtocolCallbackReceiver *receiver = [MKProtocolCallbackReceiver forProtocol:aProtocol];
    BOOL handled                         = [self handle:receiver];
    return handled ? receiver.object : theDefault;
    
}

- (BOOL)tryGetProtocol:(Protocol *)aProtocol into:(out id __strong *)outItem
{
    MKProtocolCallbackReceiver *receiver = [MKProtocolCallbackReceiver forProtocol:aProtocol];
    BOOL handled                         = [self handle:receiver];
    *outItem                             = receiver.object;
    return handled;    
}

- (id<MKPromise>)getProtocolDeferred:(Protocol *)aProtocol
{
    MKProtocolCallbackReceiver *receiver = [MKProtocolCallbackReceiver forProtocol:aProtocol];
    if ([self handle:receiver] == NO)
    {
        NSDictionary* userInfo = @{ NSLocalizedDescriptionKey :
            [NSString stringWithFormat:@"Callback protocol %@ could not be resolved", aProtocol]
        };
        
        NSError *error = [NSError errorWithDomain:MKCallbackErrorDomain
                                             code:MKCallbackErrorCallbackProtocolNotFound
                                         userInfo:userInfo];

        [receiver reject:error];
    }
    return receiver;
}

@end
