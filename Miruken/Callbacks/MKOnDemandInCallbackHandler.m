//
//  MKOnDemandInCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKOnDemandInCallbackHandler.h"
#import "MKObjectCallbackReceiver.h"

@implementation MKOnDemandInCallbackHandler
{
    MKOnDemandCallbackIn  _provider;
    MKCallbackPredicate   _condition;
}

+ (instancetype)handledBy:(MKOnDemandCallbackIn)provider when:(MKCallbackPredicate)condition
{
    if (provider == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"provider cannot be nil"
                                     userInfo:nil];            
    
    MKOnDemandInCallbackHandler *handler = [self new];
    handler->_provider                   = provider;
    handler->_condition                  = condition;
    return handler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
    {
        MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
        if (receiver.object)
        {
            return _condition(receiver.object)
                && _provider(receiver.object, composer)
                && [receiver tryResolve:receiver.object];
        }
        return NO;
    }
    return _condition(callback) && _provider(callback, composer);
}

- (void)dealloc
{
    _provider  = nil;
    _condition = nil;
}

@end
