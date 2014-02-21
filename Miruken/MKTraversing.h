//
//  Traversing.h
//  Miruken
//
//  Created by Craig Neuwirt on 1/22/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Defines the graph relationship between nodes
  */

typedef NS_ENUM(NSUInteger, MKTraversingAxes) {
    MKTraversingAxisSelf = 0,
    MKTraversingAxisRoot,
    MKTraversingAxisChild,
    MKTraversingAxisAncestor,
    MKTraversingAxisDescendant,
    MKTraversingAxisChildOrSelf,
    MKTraversingAxisAncestorOrSelf,
    MKTraversingAxisDescendantOrSelf,
    MKTraversingAxisParentSiblingOrSelf
};

/**
  Defines the contract for generalized graph traveral
  */
@protocol MKTraversing;

typedef void (^MKVisitor)(id<MKTraversing> node, BOOL *stop);

@protocol MKTraversing

@optional
- (void)traverse:(MKVisitor)visitor;  // default is TraversingAxisChild

- (void)traverse:(MKVisitor)visitor axis:(MKTraversingAxes)axis;

@end
