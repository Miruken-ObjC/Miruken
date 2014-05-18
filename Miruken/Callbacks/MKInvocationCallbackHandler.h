//
//  MKInvocationCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"
#import "MKCallbackHandler+Invocation.h"
#import "MKHandleMethod.h"

/**
  An InvocationCallbackHandler captures additional semantics when performing
  normal objective-c method invocations.  i.e. broadcast, best-effort, ...
 */

@interface MKInvocationCallbackHandler : MKCallbackHandlerDecorator

- (id)initOptions:(MKCallbackHandlerCallOptions)options handler:(MKCallbackHandler *)handler
        didInvoke:(MKHandleMethodBlock)didInvoke;

@end
