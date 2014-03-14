//
//  MKDirtyObjectTrackingMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/12/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

/**
  Protocol adopted by targets interested in tracking object changes
 */

typedef void (^MKDirtyUntrackObject)();

@protocol MKDirtyObjectTracking

@optional
- (MKDirtyUntrackObject)trackObject:(NSObject *)object;

- (void)untrackObject:(NSObject *)object;

- (void)objectBecameDirty:(NSObject *)object;

- (void)untrackAllObjects;

@end

/**
  This class is an opaque mix-in that adds dirty tracking support.
  e.g. MKDirtyObjectTrackingMixin mixInto:MyModel.class]
 */
@interface MKDirtyObjectTrackingMixin : NSObject <MKDirtyObjectTracking>

+ (void)mixInto:(Class)class;

@end
