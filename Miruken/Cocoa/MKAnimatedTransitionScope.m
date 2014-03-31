//
//  MKAnimatedTransitionScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransitionScope.h"

@implementation MKAnimatedTransitionScope

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
    [self requirePresentationPolicy].animationOptions = options;
    return self;
}

- (instancetype)duration:(NSTimeInterval)duration
{
    [self requirePresentationPolicy].animationDuration = duration;
    return self;
}

@end
