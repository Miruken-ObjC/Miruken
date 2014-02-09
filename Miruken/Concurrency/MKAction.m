//
//  MKAction.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/7/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAction.h"

@implementation MKAction

+ (void)do:(dispatch_block_t)action
{
    if (action)
        action();
}

- (void)do:(dispatch_block_t)action
{
    if (action)
        action();
}

@end
