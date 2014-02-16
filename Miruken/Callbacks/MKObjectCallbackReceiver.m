//
//  MKObjectCallbackReceiver.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/8/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKObjectCallbackReceiver.h"

@implementation MKObjectCallbackReceiver

@synthesize forClass = _class;
@synthesize object   = _object;

+ (instancetype)forClass:(Class)aClass
{
    MKObjectCallbackReceiver *receiver = [self new];
    receiver->_class                   = aClass;
    return receiver;
}

+ (instancetype)forObject:(id)callback
{
    MKObjectCallbackReceiver *receiver = [self forClass:[callback class]];
    receiver->_object                  = callback;
    return receiver;
}

- (id)resolve:(id)result
{
    if ([result isKindOfClass:_class])
    {
        _object = result;
        [super resolve:_object];
    }
    return self;
}

- (BOOL)tryResolve:(id)result
{
    if ([result isKindOfClass:_class])
    {
        _object = result;
        [super resolve:_object];
        return YES;
    }
    return NO;
}

- (BOOL)tryResolve:(id)result withKindOfClass:(BOOL)kindOfClass
{
    BOOL compatible = kindOfClass
       ? [result isKindOfClass:self.forClass]
       : [result isMemberOfClass:self.forClass];
    
    if (compatible)
    {
        _object = result;
        [super resolve:_object];
        return YES;
    }
    return NO;
}

- (id)reject:(id)reason
{
    [super reject:reason];
    return self;
}

@end
