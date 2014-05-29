//
//  MKPresentationPolicy.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationPolicy.h"

@implementation MKPresentationPolicy
{
    NSMutableArray *_options;
}

- (id)init
{
    if (self = [super init])
        _options = [NSMutableArray new];
    return self;
}

- (id)initWithOptions:(NSArray *)options
{
    if (self = [super init])
        _options = [NSMutableArray arrayWithArray:options];
    return self;
}

- (NSArray *)options
{
    return [_options copy];
}

- (id<MKPresentationOptions>)optionsWithClass:(Class)optionsClass
{
    NSUInteger idx = [self _indexOfOptionsWithClass:optionsClass];
    return (idx != NSNotFound) ? _options[idx] : nil;
}

- (void)addOrMergeOptions:(id<MKPresentationOptions>)options
{
    if ([options isKindOfClass:MKPresentationPolicy.class])
    {
        MKPresentationPolicy *policy = options;
        for (id<MKPresentationOptions> nestedOptions in policy.options)
            [self addOrMergeOptions:nestedOptions];
    }
    else
    {
        NSUInteger idx = [self _indexOfOptionsWithClass:options.class];
        if (idx != NSNotFound)
            [options mergeIntoOptions:_options[idx]];
        else
            [_options addObject:options];
    }
}

- (void)removeOptionsWithClass:(Class)optionsClass
{
    NSUInteger idx = [self _indexOfOptionsWithClass:optionsClass];
    if (idx != NSNotFound)
        [_options removeObjectAtIndex:idx];
}

- (void)applyPolicyToViewController:(UIViewController *)viewController
{
    for (id<MKPresentationOptions> options in _options)
        [options applyPolicyToViewController:viewController];
}

- (void)mergeIntoOptions:(id<MKPresentationOptions>)otherOptions
{
    if ([otherOptions isKindOfClass:MKPresentationPolicy.class])
    {
        MKPresentationPolicy *policy = otherOptions;
        for (id<MKPresentationOptions> nestedOptions in policy.options)
            [self mergeIntoOptions:nestedOptions];
    }
    else
    {
        id<MKPresentationOptions> options = [self optionsWithClass:otherOptions.class];
        [options mergeIntoOptions:otherOptions];
    }
}

- (NSUInteger)_indexOfOptionsWithClass:(Class)optionsClass
{
    return [_options indexOfObjectPassingTest:
            ^(id<MKPresentationOptions> options, NSUInteger idx, BOOL *stop) {
                return  ((*stop = [options isKindOfClass:optionsClass]));
            }];
}

@end
