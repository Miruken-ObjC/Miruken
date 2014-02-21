//
//  DepthFirstTraversal.m
//  Miruken
//
//  Created by Craig Neuwirt on 1/22/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTraversal.h"
#import "MKCollectionExtensions.h"

@implementation MKTraversal

+ (void)preOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor
{
    [self preOrderRecursive:node visitor:visitor];
}

+ (BOOL)preOrderRecursive:(id<MKTraversing>)node visitor:(MKVisitor)visitor
{
    BOOL stop = NO;
    visitor(node, &stop);
    if (stop)
        return YES;
    
    [node traverse:^(id<MKTraversing> child, BOOL *stop) {
        *stop = [self preOrderRecursive:child visitor:visitor];
    }];
    
    return NO;
}

+ (void)postOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor
{
    [self postOrderRecursive:node visitor:visitor];
}

+ (BOOL)postOrderRecursive:(id<MKTraversing>)node visitor:(MKVisitor)visitor
{
    [node traverse:^(id<MKTraversing> child, BOOL *stop) {
        *stop = [self postOrderRecursive:child visitor:visitor];
    }];
    
    BOOL stop = NO;
    visitor(node, &stop);
    return stop;
}

+ (void)levelOrder:(id<MKTraversing>)node visitor:(MKVisitor)visitor
{
    BOOL            stop  = NO;
    NSMutableArray *queue = [NSMutableArray new];
    
    [queue enqueue:node];
    while (queue.count > 0)
    {
        id<MKTraversing> next = [queue dequeue];
        visitor(next, &stop);
        if (stop)
            return;
        
        [next traverse:^(id<MKTraversing> child, BOOL *ignore) {
            [queue enqueue:child];
        }];
    }
}

@end
