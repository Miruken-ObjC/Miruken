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

- (instancetype)presentModal;

- (instancetype)presentFullScreen;

- (instancetype)presentPageSheet;

- (instancetype)presentFormSheet;

- (instancetype)presentCurrent;

- (instancetype)definesPresentationContext;

- (instancetype)providesPresentationContextTransition;

- (instancetype)transitionCoverVertical;

- (instancetype)transitionFlipHorizontal;

- (instancetype)transitionCrossDissolve;

- (instancetype)transitionPartialCurl;

- (instancetype)transition:(id<UIViewControllerTransitioningDelegate>)transition;

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy;

@end
