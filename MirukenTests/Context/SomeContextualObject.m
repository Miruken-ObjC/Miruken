//
//  SomeContextualObject.m
//  Miruken
//
//  Created by Craig Neuwirt on 1/28/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "SomeContextualObject.h"

@implementation SomeContextualObject
{
    BOOL _initWasCalled;
}

@synthesize context;

- (id)init
{
    if ((self = [super init]))
        _initWasCalled = YES;
    return self;
}

- (BOOL)initWasCalled
{
    return _initWasCalled;
}

@end
