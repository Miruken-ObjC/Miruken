//
//  MKPresentationScope.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"
#import "MKPresentationPolicy.h"

@interface MKPresentationScope : MKCallbackHandlerDecorator

@property (strong, nonatomic) MKPresentationPolicy* presentationPolicy;

+ (instancetype)for:(MKCallbackHandler *)handler;

- (MKPresentationPolicy *)requirePresentationPolicy;

@end
