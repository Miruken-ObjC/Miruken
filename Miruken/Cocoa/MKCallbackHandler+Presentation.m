//
//  MKCallbackHandler+Presentation.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Presentation.h"
#import "MKPresentationPolicyHandler.h"
#import "MKCallbackHandler+Builders.h"
#import "MKWindowOptions.h"

@implementation MKCallbackHandler (Presentation)

#pragma mark - Modal presentations

- (MKModalScope *)modal
{
    return [MKModalScope for:self];
}

- (MKTransitionScope *)transition
{
    return [MKTransitionScope for:self];
}

- (MKNavigationScope *)navigation
{
    return [MKNavigationScope for:self];
}

- (instancetype)windowRoot
{
    MKWindowOptions *windowOptions = [MKWindowOptions new];
    windowOptions.windowRoot       = YES;
    return [self presentWithOptions:windowOptions];
}

- (instancetype)newWindow
{
    MKWindowOptions *windowOptions = [MKWindowOptions new];
    windowOptions.newWindow        = YES;
    return [self presentWithOptions:windowOptions];
}

- (instancetype)presentWithOptions:(id<MKPresentationOptions>)options
{
    MKPresentationPolicy *policy = [MKPresentationPolicy new];
    [policy addOrMergeOptions:options];
    return [[MKPresentationPolicyHandler handlerWithPresentationPolicy:policy] then:self];
}

@end
