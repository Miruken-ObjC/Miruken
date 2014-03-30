//
//  MKModalPresentationScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"
#import "MKPresentationPolicy.h"

@interface MKModalPresentationScope : MKCallbackHandlerDecorator

+ (instancetype)for:(MKCallbackHandler *)handler;

- (instancetype)fullScreen;

- (instancetype)pageSheet;

- (instancetype)formSheet;

- (instancetype)currentContext;

- (instancetype)presentationStyle:(UIModalPresentationStyle)presentationStyle;

- (instancetype)coverVertical;

- (instancetype)flipHorizontal;

- (instancetype)crossDissolve;

- (instancetype)partialCurl;

- (instancetype)transitionStyle:(UIModalTransitionStyle)transitionStyle;

- (instancetype)definesPresentationContext;

- (instancetype)providesPresentationContextTransition;

@end
