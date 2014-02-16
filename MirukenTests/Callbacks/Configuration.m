//
//  Configuration.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 9/11/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

- (id)init
{
    if (self = [super init])
        _tags = [NSMutableArray new];
    return self;
}

- (id)initWithName:(NSString *)name
{
    if (self = [self init])
        _name = name;
    return self;
}

@end
