//
//  foo.m
//  Miruken
//
//  Created by Craig Neuwirt on 8/24/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MKPromiseBase

@dynamic state;

- (instancetype)await
{
    return self;
}

@end

#pragma clang diagnostic pop
