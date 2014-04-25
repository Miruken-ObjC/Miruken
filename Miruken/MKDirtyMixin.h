//
//  MKDirtyMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Protocol adopted by targets interested in dirty checking
 */

@protocol MKDirtyChecking

@optional
- (BOOL)isDirty;

- (void)clearDirty;

- (void)batchUpdates:(void (^)(void))updates;

@end

@interface MKDirtyChecking : NSObject <MKDirtyChecking>
@end

/**
  This class is an opaque mix-in that adds dirty checking support.
    e.g. MKDirtyMixin mixInto:MyModel.class]
 */

@interface MKDirtyMixin : NSObject <MKDirtyChecking>

@end
