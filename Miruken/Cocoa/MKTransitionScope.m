//
//  MKTransitionScope.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTransitionScope.h"
#import "MKAnimationOptionsTransition.h"
#import "MKPushMoveInTransition.h"
#import "MKCubeTransition.h"
#import "MKZoomTransition.h"
#import "MKExpodeTransition.h"
#import "MKNatGeoTransition.h"
#import "MKPageFlipTransition.h"
#import "MKPageFoldTransition.h"
#import "MKPortalTransition.h"
#import "MKShuffle3DTransition.h"
#import "MKSlide3DTransition.h"
#import "MKFlip3DTransition.h"
#import "MKTransitionOptions.h"

@implementation MKTransitionScope

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

- (instancetype)flipFromTop3D
{
    return [self flip3DFromPosition:MKStartingPositionTop];
}

- (instancetype)flipFromBottom3D
{
    return [self flip3DFromPosition:MKStartingPositionBottom];
}

- (instancetype)flipFromLeft3D
{
    return [self flip3DFromPosition:MKStartingPositionLeft];
}

- (instancetype)flipFromRight3D
{
    return [self flip3DFromPosition:MKStartingPositionRight];
}

- (instancetype)flipFromTopLeft3D
{
    return [self flip3DFromPosition:MKStartingPositionTopLeft];
}

- (instancetype)flipFromTopRight3D
{
    return [self flip3DFromPosition:MKStartingPositionTopRight];
}

- (instancetype)flipFromBottomLeft3D
{
    return [self flip3DFromPosition:MKStartingPositionBottomLeft];
}

- (instancetype)flipFromBottomRight3D
{
    return [self flip3DFromPosition:MKStartingPositionBottomRight];
}

- (instancetype)flip3DFromPosition:(MKStartingPosition)position
{
    return [self _setTransitionDelegate: [MKFlip3DTransition turnFromPosition:position]];
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
    return [self _setTransitionDelegate:[MKPushMoveInTransition pushFromPosition:position]];
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
    return [self _setTransitionDelegate:[MKPushMoveInTransition moveInFromPosition:position]];
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
    return [self _setTransitionDelegate:[MKPageFlipTransition new]];
}

- (instancetype)pageFold
{
    return [self _setTransitionDelegate:[MKPageFoldTransition new]];
}

- (instancetype)pageFold:(NSUInteger)folds
{
    return [self _setTransitionDelegate: [MKPageFoldTransition folds:folds]];
}

#pragma mark - extra

- (instancetype)zoom
{
    return [self _setTransitionDelegate:[MKZoomTransition new]];
}

- (instancetype)portal
{
    return [self _setTransitionDelegate:[MKPortalTransition new]];
}

- (instancetype)explode
{
    return [self _setTransitionDelegate:[MKExpodeTransition new]];
}

- (instancetype)natGeo
{
    return [self _setTransitionDelegate:[MKNatGeoTransition new]];
}

- (instancetype)natGeoFirstPartRatio:(CGFloat)ratio
{
    return [self _setTransitionDelegate: [MKNatGeoTransition natGeoFirstPartRatio:ratio]];
}

- (instancetype)slide3D
{
    return [self _setTransitionDelegate:[MKSlide3DTransition new]];
}

- (instancetype)shuffle3D
{
    return [self _setTransitionDelegate:[MKShuffle3DTransition new]];
}

- (instancetype)crossDissolve
{
    return [self animate:UIViewAnimationOptionTransitionCrossDissolve];
}

- (instancetype)horizontalCube
{
    return [self _setTransitionDelegate:[MKCubeTransition cubeAxis:MKCubeTransitionAxisHorizontal]];
}

- (instancetype)horizontalCubeAtDegrees:(CGFloat)angle
{
    MKCubeTransition *cube = [MKCubeTransition cubeAxis:MKCubeTransitionAxisHorizontal];
    cube.rotateDegrees     = angle;
    return [self _setTransitionDelegate:cube];
}

- (instancetype)verticalCube
{
    return [self _setTransitionDelegate:[MKCubeTransition cubeAxis:MKCubeTransitionAxisVertical]];
}

- (instancetype)verticalCubeAtDegrees:(CGFloat)angle
{
    MKCubeTransition *cube = [MKCubeTransition cubeAxis:MKCubeTransitionAxisVertical];
    cube.rotateDegrees     = angle;
    return [self _setTransitionDelegate:cube];
}

- (instancetype)animate:(UIViewAnimationOptions)options
{
    return [self _setTransitionDelegate: [MKAnimationOptionsTransition transitionWithOptions:options]];
}

#pragma mark - MKTransitionTraits

- (instancetype)fadeIn
{
    return [self _fade:MKTransitionFadeStyleIn];
}

- (instancetype)fadeOut
{
    return [self _fade:MKTransitionFadeStyleOut];
}

- (instancetype)fadeInOut
{
    return [self _fade:MKTransitionFadeStyleInOut];
}

- (instancetype)_fade:(MKTransitionFadeStyle)fadeStyle
{
    MKTransitionOptions *transitionOptions = [MKTransitionOptions new];
    transitionOptions.fadeStyle            = fadeStyle;
    [[self requirePresentationPolicy] addOrMergeOptions:transitionOptions];
    return self;
}

- (instancetype)duration:(NSTimeInterval)duration
{
    MKTransitionOptions *transitionOptions = [MKTransitionOptions new];
    transitionOptions.animationDuration    = duration;
    return [self _addOrMergeTransitionOptions:transitionOptions];
}

- (instancetype)perspective:(CGFloat)perspective
{
    MKTransitionOptions *transitionOptions = [MKTransitionOptions new];
    transitionOptions.perspective          = perspective;
    return [self _addOrMergeTransitionOptions:transitionOptions];
}

- (instancetype)_setTransitionDelegate:(id<UIViewControllerTransitioningDelegate>)delegate
{
    MKTransitionOptions *transitionOptions = [MKTransitionOptions new];
    transitionOptions.transitionDelegate   = delegate;
    return [self _addOrMergeTransitionOptions:transitionOptions];
}

- (instancetype)_addOrMergeTransitionOptions:(MKTransitionOptions *)transitionOptions
{
    [[self requirePresentationPolicy] addOrMergeOptions:transitionOptions];
    return self;
}

@end
