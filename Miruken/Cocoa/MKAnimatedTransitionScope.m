//
//  MKAnimatedTransitionScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAnimatedTransitionScope.h"
#import "MKAnimationOptionsTransition.h"
#import "MKPushMoveInTransition.h"
#import "MKZoomTransition.h"
#import "MKExpodeTransition.h"
#import "MKPageFlipTransition.h"
#import "MKPageFoldTransition.h"
#import "MKPortalTransition.h"
#import "MKShuffle3DTransition.h"
#import "MKSlide3DTransition.h"
#import "MKTurn3DTransition.h"

@implementation MKAnimatedTransitionScope

#pragma mark - flip

- (instancetype)flipFromLeft
{
    return [self animate:UIViewAnimationOptionTransitionFlipFromLeft];
}

- (instancetype)flipFromRight
{
    return [self animate:UIViewAnimationOptionTransitionFlipFromRight];
}

- (instancetype)flipFromTop
{
    return [self animate:UIViewAnimationOptionTransitionFlipFromTop];
}

- (instancetype)flipFromBottom
{
    return [self animate:UIViewAnimationOptionTransitionFlipFromBottom];
}

- (instancetype)horizontalTurn3D
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKTurn3DTransition turnDirection:MKTurnDirectionHorizontal];
    return self;
}

- (instancetype)verticalTurn3D
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKTurn3DTransition turnDirection:MKTurnDirectionVertical];
    return self;
}

#pragma mark - push

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

#pragma mark - move in

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

- (instancetype)moveInFromTopRight
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

#pragma mark - page

- (instancetype)curlUp
{
    return [self animate:UIViewAnimationOptionTransitionCurlUp];
}

- (instancetype)curlDown
{
    return [self animate:UIViewAnimationOptionTransitionCurlDown];
}

- (instancetype)pageFlip
{
    [self requirePresentationPolicy].transitionDelegate = [MKPageFlipTransition new];
    return self;
}

- (instancetype)pageFold
{
    [self requirePresentationPolicy].transitionDelegate = [MKPageFoldTransition new];
    return self;
}

- (instancetype)pageFold:(NSUInteger)folds
{
    [self requirePresentationPolicy].transitionDelegate = [MKPageFoldTransition folds:folds];
    return self;
}

#pragma mark - extra

- (instancetype)zoom
{
    [self requirePresentationPolicy].transitionDelegate = [MKZoomTransition new];
    return self;
}

- (instancetype)portal
{
    [self requirePresentationPolicy].transitionDelegate = [MKPortalTransition new];
    return self;
}

- (instancetype)explode
{
    [self requirePresentationPolicy].transitionDelegate = [MKExpodeTransition new];
    return self;
}

- (instancetype)slide3D
{
    [self requirePresentationPolicy].transitionDelegate = [MKSlide3DTransition new];
    return self;
}

- (instancetype)shuffle3D
{
    [self requirePresentationPolicy].transitionDelegate = [MKShuffle3DTransition new];
    return self;
}

- (instancetype)crossDissolve
{
    return [self animate:UIViewAnimationOptionTransitionCrossDissolve];
}

- (instancetype)animate:(UIViewAnimationOptions)options
{
    [self requirePresentationPolicy].transitionDelegate =
        [MKAnimationOptionsTransition transitionWithOptions:options];
    return self;
}

- (instancetype)duration:(NSTimeInterval)duration
{
    [self requirePresentationPolicy].animationDuration = duration;
    return self;
}

@end
