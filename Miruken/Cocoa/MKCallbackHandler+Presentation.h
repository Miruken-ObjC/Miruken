//
//  MKCallbackHandler+Presentation.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPresentationPolicy.h"
#import "MKModalPresentationScope.h"

typedef void (^MKConfigurePresentationPolicy)(MKPresentationPolicy *policy);

@interface MKCallbackHandler (Presentation)

- (MKModalPresentationScope *)modal;

- (instancetype)animationOptions:(UIViewAnimationOptions)options;

- (instancetype)transition:(id<UIViewControllerTransitioningDelegate>)transition;

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy;

@end
