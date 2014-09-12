//
//  NSObject+Callbacks.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+Callbacks.h"
#import "MKObjectCallbackHandler.h"
#import "MKCallbackHandler+Builders.h"
#import "MKWhen.h"

@implementation NSObject (NSObject_Callbacks)

- (MKCallbackHandler *)toCallbackHandler
{
    return [MKObjectCallbackHandler withObject:self];
}

- (MKCallbackHandler *)toCallbackHandler:(BOOL)isKindOf;
{
    return [MKObjectCallbackHandler withObject:self isKindOf:isKindOf];
}

+ (MKCallbackHandler *)accept:(MKAcceptingBlock)handler
{
    return [[MKAcceptingCallbackHandler acceptingWith:handler] whenKindOfClass:self];
}

+ (MKCallbackHandler *)provide:(MKPovidingBlock)provider
{
    return [[MKProvidingCallbackHandler providingWith:provider] whenKindOfClass:self];
}

@end