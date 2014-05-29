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

@implementation MKCallbackHandler (Presentation)

#pragma mark - Modal presentations

- (MKModalPresentationScope *)modal
{
    return [MKModalPresentationScope for:self];
}

- (MKAnimatedTransitionScope *)transition
{
    return [MKAnimatedTransitionScope for:self];
}

- (instancetype)presentWithOptions:(id<MKPresentationOptions>)options
{
    MKPresentationPolicy *policy = [MKPresentationPolicy new];
    [policy addOrMergeOptions:options];
    return [[MKPresentationPolicyHandler handlerWithPresentationPolicy:policy] then:self];
}

@end
