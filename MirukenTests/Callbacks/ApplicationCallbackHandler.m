//
//  ApplicationCallbackHandler.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "ApplicationCallbackHandler.h"
#import <UIKit/UIKit.h>

@implementation ApplicationCallbackHandler

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.launchOptions = launchOptions;
    return YES;
}

- (void)startMissleLaunch
{
    [self notHandled];
}

@end
