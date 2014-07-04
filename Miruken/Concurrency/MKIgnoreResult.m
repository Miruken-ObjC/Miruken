//
//  MKIgnoreResult.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKIgnoreResult.h"
#import "NSInvocation+Objects.h"

@implementation MKIgnoreResult

- (id)result
{
    return nil;
}

- (id)extractResultFromInvocation:(NSInvocation *)invocation
{
    return [invocation returnsObject]
         ? [invocation objectReturnValue]
         : [super extractResultFromInvocation:invocation];
}

@end
