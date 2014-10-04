//
//  MKProvidingCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/3/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKProvidingCallbackHandler.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"

@implementation MKProvidingCallbackHandler
{
    MKPovidingCallbackBlock  _provider;
}

+ (instancetype)providedBy:(MKPovidingCallbackBlock)provider
{
    if (provider == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"provider cannot be nil"
                                     userInfo:nil];
    
    MKProvidingCallbackHandler *providing = [self new];
    providing->_provider                  = provider;
    return providing;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
    {
        MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
        return [receiver tryResolve:_provider(composer)];
    }
    else if ([callback isKindOfClass:MKProtocolCallbackReceiver.class])
    {
        MKProtocolCallbackReceiver *receiver = (MKProtocolCallbackReceiver *)callback;
        return [receiver tryResolve:_provider(composer)];
    }
    return NO;
}

- (void)dealloc
{
    _provider  = nil;
}

@end
