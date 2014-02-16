//
//  MKCallbackHandlerFilter.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"

/**
  A MKCallbackHandlerFilter allows the filtering of callbacks before and/or adter they
  are handled.  In addition, it can supress the handling of them completely.
  */

typedef BOOL (^MKCallbackFilter)(id callback, id<MKCallbackHandler> composer, BOOL(^proceed)());

@interface MKCallbackHandlerFilter : MKCallbackHandlerDecorator

+ (instancetype)for:(MKCallbackHandler *)handler filter:(MKCallbackFilter)filter;

@end
