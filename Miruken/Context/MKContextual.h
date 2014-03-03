//
//  MKContextual.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/15/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContext.h"

/**
  This protocol exposes the minimal functionality to support
  contextual based operations.  This is an alternatve to the
  delegate model of communication, but with less coupling and
  ceremony.
 */

@protocol MKContextual

@optional
@property (strong, nonatomic) MKContext *context;

- (BOOL)isActiveContext;

- (void)contextChanged:(MKContext *)context;

- (void)endContext;

- (void)endContextWithObject:(id)object;

@end

/**
  This class is an opaque mix-in that adds contextual behavior to any class.  e.g.
    [UIViewController  mixinFrom:MKContextualMixin.class];
 */

@interface MKContextualMixin : NSObject

+ (void)mixInto:(Class)class;

@end

/**
  This category provides object context support.
 */
 
@interface NSObject (NSObject_Context)

+ (instancetype)allocInContext:(id)context;

+ (instancetype)allocInChildContext:(id)context;

+ (instancetype)newInContext:(id)context;

+ (instancetype)newInChildContext:(id)context;

- (MKCallbackHandler *)composer;

@end