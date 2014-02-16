//
//  ResourcesCallbackHandler.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 9/21/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "ResourcesCallbackHandler.h"
#import "ConfigurationCallbackHandler.h"
#import "Configuration.h"
#import "GetResource.h"
#import "ResourceUsage.h"

@implementation ResourcesCallbackHandler

- (BOOL)handleGetResource:(GetResource *)getResource composition:(MKCallbackHandler *)composer
{
    Configuration *configuration;
    if ([composer tryGetClass:[Configuration class] into:&configuration])
    {
        getResource.resource = [NSDictionary dictionaryWithObject:configuration.url forKey:@"url"];
        return YES;
    }
    return NO;
}

- (ResourceUsage *)provideResourceUsage:(MKCallbackHandler *)composer
{
    return [ResourceUsage new];
}

@end
