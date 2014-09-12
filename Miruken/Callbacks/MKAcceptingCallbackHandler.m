//
//  MKAcceptingCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAcceptingCallbackHandler.h"
#import "MKObjectCallbackReceiver.h"

@implementation MKAcceptingCallbackHandler
{
    MKAcceptingBlock  _handler;
}

+ (instancetype)handledBy:(MKAcceptingBlock)handler
{
    if (handler == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"handler cannot be nil"
                                     userInfo:nil];            
    
    MKAcceptingCallbackHandler *accepting = [self new];
    accepting->_handler                   = handler;
    return accepting;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
    {
        MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
        if (receiver.object)
        {
            return _handler(receiver.object, composer)
                && [receiver tryResolve:receiver.object];
        }
        return NO;
    }
    return _handler(callback, composer);
}

- (void)dealloc
{
    _handler = nil;
}

@end
