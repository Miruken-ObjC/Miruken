//
//  MKTraversingMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKTraversal.h"

/**
  Protocol adopted by targets supporting traversal.
 */

@protocol MKTraversingDelegate <MKTraversing>

@optional
- (id<MKTraversingDelegate>)parent;

- (id<NSFastEnumeration>)children;

@end

/**
  This class is an opaque mix-in that adds traversal support.
  It can only be mixed into classes conforming to the MKTraversingDelegate protocol.
  e.g. [MKTraversingMixin mixInto:ISupportTraversal.class]
 */

@interface MKTraversingMixin : NSObject <MKTraversingDelegate>

+ (void)mixInto:(Class)class;

@end
