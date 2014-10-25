//
//  MKTraversal
//  Miruken
//
//  Created by Craig Neuwirt on 1/22/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKTraversing.h"

@interface MKTraversal : NSObject

+ (void)preOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor;

+ (void)postOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor;

+ (void)levelOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor;

+ (void)reverseLevelOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor;

@end
