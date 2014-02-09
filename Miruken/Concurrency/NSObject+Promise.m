//
//  NSObject+Promise.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/30/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+Promise.h"
#import "MKDeferred.h"

@implementation NSObject (NSObject_Promise)

- (id<MKPromise>)makePromise
{
    return ([self conformsToProtocol:@protocol(MKPromise)])
         ? (id<MKPromise>)self
         : [[MKDeferred resolved:self] promise];
}

@end
