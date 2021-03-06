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

@interface MKContextual : NSObject <MKContextual>
@end

/**
  This class is an opaque mix-in that adds contextual behavior to any class.  e.g.
    [UIViewController  mixinFrom:MKContextualMixin.class];
 */

@interface MKContextualMixin : NSObject

@end
