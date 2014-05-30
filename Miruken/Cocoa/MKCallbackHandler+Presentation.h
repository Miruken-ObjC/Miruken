//
//  MKCallbackHandler+Presentation.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPresentationOptions.h"
#import "MKModalScope.h"
#import "MKTransitionScope.h"

@interface MKCallbackHandler (Presentation)

- (MKModalScope *)modal;

- (MKTransitionScope *)transition;

- (instancetype)presentWithOptions:(id<MKPresentationOptions>)options;

@end
