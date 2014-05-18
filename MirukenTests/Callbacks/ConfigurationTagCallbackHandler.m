//
//  ConfigurationTagCallbackHandler.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 9/11/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "ConfigurationTagCallbackHandler.h"
#import "Configuration.h"
#import <UIKit/UIKit.h>

@implementation ConfigurationTagCallbackHandler

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _active = YES;
}

- (BOOL)handleConfiguration:(Configuration *)config
{
    [config.tags addObject:@"secondary"];
    return YES;
}

@end
