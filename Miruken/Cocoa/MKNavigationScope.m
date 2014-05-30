//
//  MKNavigationScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKNavigationScope.h"
#import "MKNavigationOptions.h"

@implementation MKNavigationScope

- (instancetype)_addOrMergeTransitionOptions:(MKTransitionOptions *)transitionOptions
{
    MKNavigationOptions *navOptions = [MKNavigationOptions new];
    navOptions.transition           = transitionOptions;
    [[self requirePresentationPolicy] addOrMergeOptions:navOptions];
    return self;
}

@end
