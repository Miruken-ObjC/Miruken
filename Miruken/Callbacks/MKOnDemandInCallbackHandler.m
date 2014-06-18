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
    MKOnDemandCallbackIn  _handler;
    MKWhenPredicate       _condition;
}

+ (instancetype)handledBy:(MKOnDemandCallbackIn)provider when:(MKWhenPredicate)condition
{
    if (provider == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"provider cannot be nil"
                                     userInfo:nil];            
    
    MKOnDemandInCallbackHandler *onDemand = [self new];
    onDemand->_handler                    = provider;
    onDemand->_condition                  = condition;
    return onDemand;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
    {
        MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
        if (receiver.object)
        {
            return _condition(receiver.object)
                && _handler(receiver.object, composer)
                && [receiver tryResolve:receiver.object];
        }
        return NO;
    }
    return _condition(callback) && _handler(callback, composer);
}

- (void)dealloc
{
    _handler   = nil;
    _condition = nil;
}

@end
