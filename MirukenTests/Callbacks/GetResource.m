//
//  GetResource.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 9/21/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "GetResource.h"

@implementation GetResource

+ (GetResource *)withId:(NSString *)resourceId
{
    GetResource *getResource = [GetResource new];
    getResource->_resourceId = resourceId;
    return getResource;
}

@end
