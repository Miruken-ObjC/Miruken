//
//  MKCallbackHandler+Presentation.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPresentationPolicy.h"

typedef BOOL (^MKConfigurePresentationPolicy)(MKPresentationPolicy *policy);

@interface MKCallbackHandler (Presentation)

- (instancetype)modal:(BOOL)modal;

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy;

- (instancetype)presentationPolicy:(MKConfigurePresentationPolicy)configurePolicy;

@end
