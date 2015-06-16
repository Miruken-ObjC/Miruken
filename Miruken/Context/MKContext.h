//
//  MKContext.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/11/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCompositeCallbackHandler.h"
#import "MKTraversing.h"

@protocol MKContext;

/**
  The state of the context.
 */

typedef NS_ENUM(NSUInteger, MKContextState) {
    MKContextStateActive = 0,
    MKContextStateEnding,
    MKContextStateEnded
};

typedef void (^MKContextUnsubscribe)();
typedef void (^MKContextAction)(id<MKContext> context);

/**
  Enables the tracking of Context lifecycle changes.
 */
@protocol MKContextObserver <NSObject>

@optional
- (void)contextWillEnd:(id<MKContext>)context;

- (void)contextDidEnd:(id<MKContext>)context;

- (void)childContextWillEnd:(id<MKContext>)childContext;

- (void)childContextDidEnd:(id<MKContext>)childContext;

@end

/**
  A MKContext represents the scope at a give point in time.  It has a beginning and
  and end (lifecycle).  It can handle callbacks as well as notify consumers of its
  lifecycle changes.  In addition, it has a parent-child relationship and thus can
  participate in a hierarchy.
 */

@protocol MKContext <MKCallbackHandler, MKTraversing>

@property (readonly, nonatomic)         MKContextState  state;
@property (readonly, strong, nonatomic) id<MKContext>   parent;

- (BOOL)hasChildren;

- (id<MKContext>)rootContext;

- (id<MKContext>)add:(id)object;

- (id<MKContext>)newChildContext;

- (MKContextUnsubscribe)subscribe:(id<MKContextObserver>)observer;

- (MKContextUnsubscribe)subscribe:(id<MKContextObserver>)observer retain:(BOOL)retain;

- (BOOL)handle:(id)callback axis:(MKTraversingAxes)axis;

- (BOOL)handle:(id)callback greedy:(BOOL)greedy axis:(MKTraversingAxes)axis;

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
          axis:(MKTraversingAxes)axis;

- (id<MKContext>)unwindToRootContext;

- (void)unwind;

- (void)end;

@end


@interface MKContext : MKCompositeCallbackHandler <MKContext>

@property (readonly, strong, nonatomic) MKContext *parent;

- (instancetype)rootContext;

- (instancetype)add:(id)object;

- (instancetype)newChildContext;

- (instancetype)unwindToRootContext;

@end
