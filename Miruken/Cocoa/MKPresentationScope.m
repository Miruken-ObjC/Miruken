//
//  MKPresentationScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationScope.h"

@implementation MKPresentationScope

+ (instancetype)for:(MKCallbackHandler *)handler
{
    return [[self alloc] initWithDecoratee:handler];
}

- (MKPresentationPolicy *)requirePresentationPolicy
{
    if (_presentationPolicy == nil)
        _presentationPolicy = [MKPresentationPolicy new];
    return _presentationPolicy;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    BOOL handled = NO;
    if (self.presentationPolicy && [callback isKindOfClass:MKPresentationPolicy.class])
    {
        [self.presentationPolicy mergeIntoPolicy:callback];
        handled = YES;
    }
    return (handled && greedy == NO)
        || [super handle:callback greedy:greedy composition:composer];
}

@end
