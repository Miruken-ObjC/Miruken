//
//  MKCallbackHandlerDecorator.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  Decorates a MKCallbackHandler using the Decorater Pattern.
  */

@interface MKCallbackHandlerDecorator : MKCallbackHandler

@property (readonly, strong, nonatomic) MKCallbackHandler *decoratee;

- (id)initWithDecoratee:(MKCallbackHandler *)decoratee;

@end
