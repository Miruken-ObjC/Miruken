//
//  MKModalPresentationScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationScope.h"

@interface MKModalPresentationScope : MKPresentationScope

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
