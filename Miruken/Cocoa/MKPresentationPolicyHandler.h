//
//  MKPresentationPolicyHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPresentationPolicy.h"

@interface MKPresentationPolicyHandler : MKCallbackHandler

@property (readonly, copy, nonatomic) MKPresentationPolicy *presentationPolicy;

+ (instancetype)handlerWithPresentationPolicy:(MKPresentationPolicy *)policy;

@end
