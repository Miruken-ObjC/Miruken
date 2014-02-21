//
//  MKContext+Traversal.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/12/13.
//  Copyright (c) 2013 ZixCorp. All rights reserved.
//

#import "MKContext.h"

@interface MKContext (MKContext_Traversal)

- (instancetype)SELF;

- (instancetype)root;

- (instancetype)child;

- (instancetype)ancestor;

- (instancetype)descendant;

- (instancetype)childOrSelf;

- (instancetype)ancestorOrSelf;

- (instancetype)descendantOrSelf;

- (instancetype)parentSiblingOrSelf;

@end
