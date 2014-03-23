//
//  NSObject+Context.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKContext.h"

@interface NSObject (NSObject_Context)

+ (instancetype)allocInContext:(id)context;

+ (instancetype)allocInChildContext:(id)context;

+ (instancetype)newInContext:(id)context;

+ (instancetype)newInChildContext:(id)context;

- (MKCallbackHandler *)composer;

@end
