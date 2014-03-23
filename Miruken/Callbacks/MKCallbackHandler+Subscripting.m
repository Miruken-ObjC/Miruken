//
//  CallbackHandler+Subscripting.m
//  Miruken
//
//  Created by Craig Neuwirt on 8/13/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Subscripting.h"
#import "MKCallbackHandler+Resolvers.h"
#import <objc/runtime.h>

static id kProtocolClass;

@implementation MKCallbackHandler (Subscripting)

+ (void)load
{
    kProtocolClass = objc_getClass("Protocol");
}

- (id)objectForKeyedSubscript:(id)classOrProtocolKey
{
    Class class = object_getClass(classOrProtocolKey);
    
    if (class_isMetaClass(class))
        return [self getClass:classOrProtocolKey orDefault:nil];
    
    if (class == kProtocolClass)
        return [self getProtocol:classOrProtocolKey orDefault:nil];
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:
                                           @"Invalid index type %@.  Must be a class or protocol.",
                                           [classOrProtocolKey class]]
                                 userInfo:nil];
}

@end
