//
//  NSObject+Callbacks.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKAcceptingCallbackHandler.h"
#import "MKProvidingCallbackHandler.h"

/**
  NSObject category for constructing CallbackHandlers based on instances or classes.
  */

@interface NSObject (NSObject_Callbacks)

- (MKCallbackHandler *)toCallbackHandler;

- (MKCallbackHandler *)toCallbackHandler:(BOOL)isKindOf;

+ (MKCallbackHandler *)accept:(MKAcceptingCallbackBlock)handler;

+ (MKCallbackHandler *)provide:(MKPovidingCallbackBlock)provider;

@end
