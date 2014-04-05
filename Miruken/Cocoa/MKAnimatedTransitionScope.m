//
//  MKAnimatedTransitionScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransitionScope.h"
#import "MKViewAnimationOptionsTransition.h"
#import "MKPushMoveInTransition.h"

@implementation MKAnimatedTransitionScope

#pragma mark - Flip

- (instancetype)flipFromLeft
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromLeft];
}

- (instancetype)flipFromRight
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (instancetype)flipFromTop
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromTop];
}

- (instancetype)flipFromBottom
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromBottom];
}

#pragma mark - Curl

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

#pragma mark - Push 

- (instancetype)pushFromTop
{
    return [self pushFromPosition:MKStartingPositionTop];
}

- (instancetype)pushFromBottom
{
    return [self pushFromPosition:MKStartingPositionBottom];
}

- (instancetype)pushFromLeft
{
    return [self pushFromPosition:MKStartingPositionLeft];
}

- (instancetype)pushFromRight
{
    return [self pushFromPosition:MKStartingPositionRight];
}

- (instancetype)pushFromTopLeft
{
    return [self pushFromPosition:MKStartingPositionTopLeft];
}

- (instancetype)pushFromTopRight
{
    return [self pushFromPosition:MKStartingPositionTopRight];
}

- (instancetype)pushFromBottomLeft
{
    return [self pushFromPosition:MKStartingPositionBottomLeft];
}

- (instancetype)pushFromBottomRight
{
    return [self pushFromPosition:MKStartingPositionBottomRight];
}

- (instancetype)pushFromPosition:(MKStartingPosition)position
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKPushMoveInTransition pushFromPosition:position];
    return self;
}

#pragma mark - Move In

- (instancetype)moveInFromTop
{
    return [self moveInFromPosition:MKStartingPositionTop];
}

- (instancetype)moveInFromBottom
{
    return [self moveInFromPosition:MKStartingPositionBottom];
}

- (instancetype)moveInFromLeft
{
    return [self moveInFromPosition:MKStartingPositionLeft];
}

- (instancetype)moveInFromRight
{
    return [self moveInFromPosition:MKStartingPositionRight];
}

- (instancetype)moveInFromTopLeft
{
    return [self moveInFromPosition:MKStartingPositionTopLeft];
}

- (instancetype)moveFromTopRight
{
    return [self moveInFromPosition:MKStartingPositionTopRight];
}

- (instancetype)moveInFromBottomLeft
{
    return [self moveInFromPosition:MKStartingPositionBottomLeft];
}

- (instancetype)moveInFromBottomRight
{
    return [self moveInFromPosition:MKStartingPositionBottomRight];
}

- (instancetype)moveInFromPosition:(MKStartingPosition)position
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKPushMoveInTransition moveInFromPosition:position];
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
