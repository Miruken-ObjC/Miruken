//
//  MKDynamicCallbackHandlerExtension.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/24/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDynamicCallbackHandlerExtension.h"
#import "MKMixin.h"

@implementation MKDynamicCallbackHandlerExtension

+ (void)install
{
    [MKDynamicCallbackHandler mixinFrom:self followInheritance:YES force:NO];
}

- (MKDynamicCallbackHandler *)handler
{
    return (MKDynamicCallbackHandler *)self;
}

@end
