//
//  NSObject+Promise.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/30/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+BuildPromise.h"
#import "MKDeferred.h"

@implementation NSObject (NSObject_BuildPromise)

- (BOOL)isPromise
{
    return [self conformsToProtocol:@protocol(MKPromise)];
}

- (id<MKPromise>)makePromise
{
    return ([self conformsToProtocol:@protocol(MKPromise)])
         ? (id<MKPromise>)self
         : [[MKDeferred resolved:self] promise];
}

@end
