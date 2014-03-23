//
//  CallbackHandler+Resolvers.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPromise.h"

/**
  MKCallbackHandler category for resolving callbacks using more intuitive verbage.
  */

@interface MKCallbackHandler (Resolvers)

- (id)getClass:(Class)aClass orDefault:(id)theDefault;

- (BOOL)tryGetClass:(Class)aClass into:(out id __strong *)outItem;

- (id<MKPromise>)getClassDeferred:(Class)aClass;

- (id)getProtocol:(Protocol *)aProtocol orDefault:(id)theDefault;

- (BOOL)tryGetProtocol:(Protocol *)aProtocol into:(out id __strong *)outItem;

- (id<MKPromise>)getProtocolDeferred:(Protocol *)aProtocol;

- (id<MKPromise>)handleDeferred:(id)callback;

@end