//
//  MKCompositeCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import <Foundation/Foundation.h>

/**
  A MKCompositeCallbackHandler uses the Composite Pattern to construct a MKCallbackHandler
  from one or more child MKCallbackHandlers.  Handlers are called until one can handle the
  callback, unless greedy is specified in which all of them are called.
  */

@interface MKCompositeCallbackHandler : MKCallbackHandler

+ (instancetype)withHandler:(id)handler;

+ (instancetype)withHandlers:(id)handler, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)addHandler:(id)handler;

- (instancetype)addHandlers:(id)handler, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)insertHandler:(id)handler atIndex:(NSUInteger)index;

- (instancetype)insertHandler:(id)handler afterClass:(Class)exactClass;

- (instancetype)insertHandler:(id)handler beforeClass:(Class)exactClass;

- (instancetype)replaceHandler:(id)handler forClass:(Class)exactClass;

- (instancetype)removeHandler:(id)handler;

- (instancetype)removeHandlers:(id)handler, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)removeHandlerAtIndex:(NSUInteger)index;

@end
