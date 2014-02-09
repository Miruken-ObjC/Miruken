//
//  NSInvocation+Objects.m
//  Concurrency
//
//  Created by Craig Neuwirt on 2/7/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.

#import "NSInvocation+Objects.h"

@implementation NSInvocation (NSInvocation_Objects)

- (BOOL)returnsObject
{
    return (strcmp([self.methodSignature methodReturnType], @encode(id)) == 0);
}

- (id)objectReturnValue
{
    // result is __strong by default, but getReturnValue does not transfer ownership
    __unsafe_unretained id result;
    [self getReturnValue:&result];
    return result;
}

- (void)setObjectReturnValue:(id)returnValue
{
    // returnValue is __strong by default, but setReturnValue does not transfer ownership
    __autoreleasing id retained = returnValue;
    [self setReturnValue:&retained];
}

@end
