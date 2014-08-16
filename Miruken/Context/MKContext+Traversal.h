//
//  MKContext+Traversal.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/12/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKContext.h"

@interface MKContext (MKContext_Traversal)

- (instancetype)SELF;

- (instancetype)root;

- (instancetype)child;

- (instancetype)sibling;

- (instancetype)ancestor;

- (instancetype)descendant;

- (instancetype)childOrSelf;

- (instancetype)siblingOrSelf;

- (instancetype)ancestorOrSelf;

- (instancetype)descendantOrSelf;

- (instancetype)parentSiblingOrSelf;

@end
