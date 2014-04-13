//
//  MKAnimatedTransitionScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationScope.h"
#import "MKStartingPosition.h"

@interface MKAnimatedTransitionScope : MKPresentationScope

#pragma mark - flip

- (instancetype)flipFromLeft;

- (instancetype)flipFromRight;

- (instancetype)flipFromTop;

- (instancetype)flipFromBottom;

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

#pragma mark - curl

- (instancetype)curlUp;

- (instancetype)curlDown;

#pragma mark - extra 

- (instancetype)crossDissolve;

- (instancetype)zoom;

- (instancetype)portal;

- (instancetype)slide3D;

- (instancetype)shuffle3D;

- (instancetype)animate:(UIViewAnimationOptions)options;

- (instancetype)duration:(NSTimeInterval)duration;

@end
