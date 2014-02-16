//
//  MKCascadeCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/8/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  A MKCascadeCallbackHandler represents a choice.  If the first MKCallbackHandler does
  not handle the callback, the second MKCallbackHandler is given an opportunity.  It
  supports short-circuited handling unless greedy is requested in which both handlers
  are given the opportunity the handle the callback.
  */

@interface MKCascadeCallbackHandler : MKCallbackHandler

+ (instancetype)withHandler:(MKCallbackHandler *)aHandler cascadeTo:(MKCallbackHandler *)anotherHandler;

@end
