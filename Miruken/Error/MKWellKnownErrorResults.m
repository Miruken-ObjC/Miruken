//
//  MKWellKnownErrorResults.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/11/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKWellKnownErrorResults.h"

static id _continue, _retry, _errorInProgress;

@implementation MKWellKnownErrorResults

+ (void)initialize
{
    if (self == MKWellKnownErrorResults.class)
    {
        _continue        = [NSObject alloc];
        _retry           = [NSObject alloc];
        _errorInProgress = [NSObject alloc];
    }
}

+ (id)continue
{
    return _continue;
}

+ (id)retry
{
    return _retry;
}

+ (id)errorInProgress
{
    return _errorInProgress;
}

@end
