//
//  MKTypeOf.m
//  Miruken
//
//  Created by Craig Neuwirt on 8/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTypeOf.h"
#import <objc/runtime.h>

static id kProtocolClass;
static id kBlockClass;

@implementation MKTypeOf


+ (void)initialize
{
    if (self == MKTypeOf.class)
    {
        kProtocolClass = objc_getClass("Protocol");
        kBlockClass    = [^() {} class];
    }
}

+ (MKIdType)id:(id)anything
{
    if (anything == nil)
        return MKIdTypeNil;
    
    if ([anything class] == kBlockClass)
        return MKIdTypeBlock;
    
    Class class = object_getClass(anything);
    
    if (class_isMetaClass(class))
        return MKIdTypeClass;
    
    if (class == kProtocolClass)
        return MKIdTypeProtocol;
    
    return MKIdTypeObject;
}

@end
