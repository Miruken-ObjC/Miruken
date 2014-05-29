//
//  MKCallbackHandler+Presentation.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPresentationOptions.h"
#import "MKModalPresentationScope.h"
#import "MKAnimatedTransitionScope.h"

@interface MKCallbackHandler (Presentation)

- (MKModalPresentationScope *)modal;

- (MKAnimatedTransitionScope *)transition;

- (instancetype)presentWithOptions:(id<MKPresentationOptions>)options;

@end
