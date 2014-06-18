//
//  MKOnDemandInCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKWhen.h"

/**
  An MKOnDemandInCallbackHandler provides on-demand support for accepting callbacks.
  */

@interface MKOnDemandInCallbackHandler : MKCallbackHandler

+ (instancetype)handledBy:(MKOnDemandCallbackIn)handler when:(MKWhenPredicate)condition;

@end
