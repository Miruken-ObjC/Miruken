//
//  MKAnimatedTransitionScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransitionScope.h"

@implementation MKAnimatedTransitionScope
{
    MKPresentationPolicy *_presentationPolicy;
}

+ (instancetype)for:(MKCallbackHandler *)handler
{
    return [[self alloc] initWithDecoratee:handler];
}

- (instancetype)flipFromLeft
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromLeft];
}

- (instancetype)flipFromRight
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (instancetype)curlUp
{
    return [self animationOptions:UIViewAnimationOptionTransitionCurlUp];
}

- (instancetype)curlDown
{
    return [self animationOptions:UIViewAnimationOptionTransitionCurlDown];
}

- (instancetype)crossDissolve
{
    return [self animationOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (instancetype)flipFromTop
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromTop];
}

- (instancetype)flipFromBottom
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromBottom];
}

- (instancetype)animationOptions:(UIViewAnimationOptions)options
{
    if (_presentationPolicy == nil)
        _presentationPolicy = [MKPresentationPolicy new];
    _presentationPolicy.animationOptions = options;
    return self;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if (_presentationPolicy && [callback isKindOfClass:MKPresentationPolicy.class])
    {
        [_presentationPolicy mergeIntoPolicy:callback];
        return YES;
    }
    return [self.decoratee handle:callback greedy:greedy];
}

@end
