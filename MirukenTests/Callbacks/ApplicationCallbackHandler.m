//
//  ApplicationCallbackHandler.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "ApplicationCallbackHandler.h"
#import "NSObject+Context.h"
#import <UIKit/UIKit.h>

@implementation ApplicationCallbackHandler

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.launchOptions = launchOptions;
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _active = YES;
}

- (BOOL)startMissleLaunch
{
    [(id<UIApplicationDelegate>)self.composer applicationDidBecomeActive:[UIApplication sharedApplication]];
    return YES;
}

@end
