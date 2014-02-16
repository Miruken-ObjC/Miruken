//
//  DynamicCallbackHandler+HandleMethod.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDynamicCallbackHandler.h"

/**
  MKDynamicCallbackHandler category for extending dynamic callback handling with
  conventions for method invocations.  To preserve the normal objective-c calling
  experience, any method not known directly by a MKCallbackHandler will be packaged
  up in a MKHandleMethod callback and handled like any regular callback.   This
  category defines the conventions used to map these invocations to actual instance
  methods on a callback handler (or delegate).
 */

@interface MKDynamicCallbackHandler (MKDynamicCallbackHandler_HandleMethod)

@end
