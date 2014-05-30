//
//  MKTransitionScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationScope.h"
#import "MKTransitionTraits.h"
#import "MKStartingPosition.h"

@interface MKTransitionScope : MKPresentationScope <MKTransitionTraits>

#pragma mark - flip

- (instancetype)flipFromLeft;

- (instancetype)flipFromRight;

- (instancetype)flipFromTop;

- (instancetype)flipFromBottom;

- (instancetype)flipFromTop3D;

- (instancetype)flipFromBottom3D;

- (instancetype)flipFromLeft3D;

- (instancetype)flipFromRight3D;

- (instancetype)flipFromTopLeft3D;

- (instancetype)flipFromTopRight3D;

- (instancetype)flipFromBottomLeft3D;

- (instancetype)flipFromBottomRight3D;

- (instancetype)flip3DFromPosition:(MKStartingPosition)position;

#pragma mark - push

- (instancetype)pushFromTop;

- (instancetype)pushFromBottom;

- (instancetype)pushFromLeft;

- (instancetype)pushFromRight;

- (instancetype)pushFromTopLeft;

- (instancetype)pushFromTopRight;

- (instancetype)pushFromBottomLeft;

- (instancetype)pushFromBottomRight;

- (instancetype)pushFromPosition:(MKStartingPosition)position;

#pragma mark - move in

- (instancetype)moveInFromTop;

- (instancetype)moveInFromBottom;

- (instancetype)moveInFromLeft;

- (instancetype)moveInFromRight;

- (instancetype)moveInFromTopLeft;

- (instancetype)moveInFromTopRight;

- (instancetype)moveInFromBottomLeft;

- (instancetype)moveInFromBottomRight;

- (instancetype)moveInFromPosition:(MKStartingPosition)position;

#pragma mark - page

- (instancetype)curlUp;

- (instancetype)curlDown;

- (instancetype)pageFlip;

- (instancetype)pageFold;

- (instancetype)pageFold:(NSUInteger)folds;

#pragma mark - extra 

- (instancetype)zoom;

- (instancetype)portal;

- (instancetype)explode;

- (instancetype)slide3D;

- (instancetype)shuffle3D;

- (instancetype)crossDissolve;

- (instancetype)horizontalCube;

- (instancetype)horizontalCubeAtDegrees:(CGFloat)angle;

- (instancetype)verticalCube;

- (instancetype)verticalCubeAtDegrees:(CGFloat)angle;

- (instancetype)natGeo;

- (instancetype)natGeoFirstPartRatio:(CGFloat)ratio;

- (instancetype)animate:(UIViewAnimationOptions)options;

@end
