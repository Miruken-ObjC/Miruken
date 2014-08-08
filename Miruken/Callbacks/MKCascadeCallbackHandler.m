//
//  MKCascadeCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/8/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCascadeCallbackHandler.h"

@implementation MKCascadeCallbackHandler
{
    id<MKCallbackHandler>  _handlerA;
    id<MKCallbackHandler>  _handlerB;
}

+ (instancetype)withHandler:(MKCallbackHandler *)aHandler cascadeTo:(MKCallbackHandler *)anotherHandler;
{
    MKCascadeCallbackHandler *cascadeHandler = [self alloc];
    cascadeHandler->_handlerA                = aHandler;
    cascadeHandler->_handlerB                = anotherHandler;
    return cascadeHandler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    BOOL handled = greedy
       ? [_handlerA handle:callback greedy:YES composition:composer]
           |  [_handlerB handle:callback greedy:YES composition:composer]
       : [_handlerA handle:callback greedy:NO composition:composer]
           || [_handlerB handle:callback greedy:NO composition:composer];
    return handled || [super handle:callback greedy:greedy composition:composer];
}

- (void)dealloc
{
    _handlerA = nil;
    _handlerB = nil;
}

@end
