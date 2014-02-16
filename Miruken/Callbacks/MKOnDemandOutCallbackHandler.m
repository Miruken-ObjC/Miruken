//
//  MKProviderOutCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/3/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKOnDemandOutCallbackHandler.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"

@implementation MKOnDemandOutCallbackHandler
{
    MKOnDemandCallbackOut  _provider;
    MKCallbackPredicate    _condition;
}

+ (instancetype)providedBy:(MKOnDemandCallbackOut)provider when:(MKCallbackPredicate)condition
{
    if (provider == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"provider cannot be nil"
                                     userInfo:nil];
    
    MKOnDemandOutCallbackHandler *handler = [self new];
    handler->_provider                    = provider;
    handler->_condition                   = condition;
    return handler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
    {
        MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
        if (_condition(receiver.forClass))
        {
            id callback = _provider(composer);
            return [receiver tryResolve:callback];
        }
    }
    else if ([callback isKindOfClass:MKProtocolCallbackReceiver.class])
    {
        MKProtocolCallbackReceiver *receiver = (MKProtocolCallbackReceiver *)callback;
        if (_condition(receiver.forProtocol))
        {
            id callback = _provider(composer);
            return [receiver tryResolve:callback];
        }
    }
    return NO;
}

- (void)dealloc
{
    _provider  = nil;
    _condition = nil;
}

@end
