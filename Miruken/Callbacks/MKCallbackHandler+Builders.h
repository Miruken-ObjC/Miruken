//
//  CallbackHandler+Builders.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
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

+ (instancetype)acceptingClass:(Class)aClass handle:(MKOnDemandCallbackIn)provider;

+ (instancetype)acceptingProtocol:(Protocol *)aProtocol handle:(MKOnDemandCallbackIn)provider;

+ (instancetype)providingClass:(Class)aClass handle:(MKOnDemandCallbackOut)provider;

+ (instancetype)providingProtocol:(Protocol *)aProtocol handle:(MKOnDemandCallbackOut)provider;

@end

