//
//  MKCallbackHandler+Presentation.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPresentationPolicy.h"

typedef void (^MKConfigurePresentationPolicy)(MKPresentationPolicy *policy);

@interface MKCallbackHandler (Presentation)

#pragma mark - Modal presentations

- (instancetype)presentModal;

- (instancetype)presentFullScreen;

- (instancetype)presentPageSheet;

- (instancetype)presentFormSheet;

- (instancetype)presentCurrent;

- (instancetype)presentationStyle:(UIModalPresentationStyle)presentationStyle;

#pragma mark - Modal transitions

- (instancetype)modalTransitionCoverVertical;

- (instancetype)modalTransitionFlipHorizontal;

- (instancetype)modalTransitionCrossDissolve;

- (instancetype)modalTransitionPartialCurl;

- (instancetype)modalTransitionStyle:(UIModalTransitionStyle)transitionStyle;

#pragma mark - Animation options

- (instancetype)transitionFlipFromLeft;

- (instancetype)transitionFlipFromRight;

- (instancetype)transitionCurlUp;

- (instancetype)transitionCurlDown;

- (instancetype)transitionCrossDissolve;

- (instancetype)transitionFlipFromTop;

- (instancetype)transitionFlipFromBottom;

- (instancetype)animationOptions:(UIViewAnimationOptions)options;

- (instancetype)definesPresentationContext;

- (instancetype)providesPresentationContextTransition;

- (instancetype)transition:(id<UIViewControllerTransitioningDelegate>)transition;

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy;

@end
