//
//  MKAnimatedTransitionScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransitionScope.h"
#import "MKViewAnimationOptionsTransition.h"
#import "MKAnimatedPushTransition.h"

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

- (instancetype)pushFromTop
{
    return [self pushFrom:MKStartingPositionTop];
}

- (instancetype)pushFromBottom
{
    return [self pushFrom:MKStartingPositionBottom];
}

- (instancetype)pushFromLeft
{
    return [self pushFrom:MKStartingPositionLeft];
}

- (instancetype)pushFromRight
{
    return [self pushFrom:MKStartingPositionRight];
}

- (instancetype)pushFromTopLeft
{
    return [self pushFrom:MKStartingPositionTopLeft];
}

- (instancetype)pushFromTopRight
{
    return [self pushFrom:MKStartingPositionTopRight];
}

- (instancetype)pushFromBottomLeft
{
    return [self pushFrom:MKStartingPositionBottomLeft];
}

- (instancetype)pushFromBottomRight
{
    return [self pushFrom:MKStartingPositionBottomRight];
}

- (instancetype)pushFrom:(MKStartingPosition)position
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKAnimatedPushTransition pushFromPosition:position];
    return self;
}

- (instancetype)animationOptions:(UIViewAnimationOptions)options
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKViewAnimationOptionsTransition transitionWithOptions:options];
    return self;
}

- (instancetype)duration:(NSTimeInterval)duration
{
    [self requirePresentationPolicy].animationDuration = duration;
    return self;
}

@end
