//
//  CallbackHandler+Builders.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKAcceptingCallbackHandler.h"
#import "MKProvidingCallbackHandler.h"
#import "MKWhen.h"

/**
  MKCallbackHandler category for constructing callback handlers using more intuitive verbage.
  */

@interface MKCallbackHandler (Builders)

- (instancetype)when:(MKWhenPredicate)condition;

- (instancetype)whenKindOfClass:(Class)aClass;

- (instancetype)whenMemberOfClass:(Class)aClass;

- (instancetype)whenConformsToProtocol:(Protocol *)protocol;

- (instancetype)whenPredicate:(NSPredicate *)predicate;

- (instancetype)then:(MKCallbackHandler *)handler;

- (instancetype)thenAll:(MKCallbackHandler *)handler, ...;

+ (MKAcceptingCallbackHandler *)acceptingWith:(MKAcceptingBlock)handler;

+ (MKProvidingCallbackHandler *)providingWith:(MKPovidingBlock)provider;

@end

