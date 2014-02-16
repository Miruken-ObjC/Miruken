//
//  MKConditionCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/12/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"

/**
  A MKConditionCallbackHandler decorates a MKCallbackHandler with a condition.
  If the condition is not satisfied then the CallbackHandler is not called.
  */

@interface MKConditionCallbackHandler : MKCallbackHandlerDecorator

+ (instancetype)for:(MKCallbackHandler *)handler when:(MKCallbackPredicate)condition;
                                                              
@end
