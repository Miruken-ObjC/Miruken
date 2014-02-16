//
//  NSObject+ResolvePromise.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+ResolvePromise.h"
#import "MKHandleMethod.h"
#import "NSInvocation+Objects.h"

@implementation NSObject (NSObject_ResolvePromise)

- (id<MKPromise>)effectivePromise
{
    // Promises are resolved for the following scenarios:
    //    - callbacks that are promises (e.g. deferred receivers)
    //    - method invocations that return a promise
    
    if ([self isPromise])
    {
        return (id<MKPromise>)self;
    }
    else if ([self isKindOfClass:MKHandleMethod.class])
    {
        NSInvocation *invocation = [((MKHandleMethod *)self) invocation];
        if ([invocation returnsObject])
        {
            id result = [invocation objectReturnValue];
            if ([result conformsToProtocol:@protocol(MKPromise)])
                return (id<MKPromise>)result;
        }
    }
    
    return nil;
}

@end

