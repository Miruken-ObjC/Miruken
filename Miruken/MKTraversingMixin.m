//
//  MKTraversingMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTraversingMixin.h"
#import "MKMixingIn.h"

@implementation MKTraversing

+ (void)initialize
{
    if (self == MKTraversing.class)
        [MKTraversingMixin mixInto:self];
}

@end

@implementation MKTraversingMixin

+ (void)verifyCanMixIntoClass:(Class)targetClass
{
    if ([targetClass conformsToProtocol:@protocol(MKTraversingDelegate)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The TraversingMixin requires the target class "
                                                "to conform to the TraversingDelegate protocol."
                                     userInfo:nil];
}

- (BOOL)canTraverseAxis:(MKTraversingAxes)axis
{
    return [self validateAxis:axis require:NO];
}

- (void)traverse:(MKVisitor)visitor
{
    [self traverse:visitor axis:MKTraversingAxisChild];
}

- (void)traverse:(MKVisitor)visitor axis:(MKTraversingAxes)axis
{
    [self validateAxis:axis require:YES];
    
    switch (axis)
    {
        case MKTraversingAxisSelf:
            [self traverseSelf:visitor];
            break;
            
        case MKTraversingAxisRoot:
            [self traverseRoot:visitor];
            break;
      
        case MKTraversingAxisChild:
            [self traverseChildren:visitor withSelf:NO];
            break;

        case MKTraversingAxisSibling:
             [self traverseParentSiblingOrSelf:visitor withSelf:NO andParent:NO];
            break;
            
        case MKTraversingAxisChildOrSelf:
            [self traverseChildren:visitor withSelf:YES];
            break;
            
        case MKTraversingAxisSiblingOrSelf:
            [self traverseParentSiblingOrSelf:visitor withSelf:YES andParent:NO];
            break;
            
        case MKTraversingAxisAncestor:
            [self traverseAncestors:visitor withSelf:NO];
            break;
            
        case MKTraversingAxisAncestorOrSelf:
            [self traverseAncestors:visitor withSelf:YES];
            break;
            
        case MKTraversingAxisDescendant:
            [self traverseDescendants:visitor withSelf:NO];
            break;
            
        case MKTraversingAxisDescendantReverse:
            [self traverseDescendantsReverse:visitor withSelf:NO];
            break;
            
        case MKTraversingAxisDescendantOrSelf:
            [self traverseDescendants:visitor withSelf:YES];
            break;
            
        case MKTraversingAxisDescendantOrSelfReverse:
            [self traverseDescendantsReverse:visitor withSelf:YES];
            break;

        case MKTraversingAxisParentSiblingOrSelf:
            [self traverseParentSiblingOrSelf:visitor withSelf:YES andParent:YES];
            break;
    }
}

- (void)traverseSelf:(MKVisitor)visitor
{
    BOOL stop;
    visitor(self, &stop);
}

- (void)traverseRoot:(MKVisitor)visitor
{
    BOOL stop;
    id<MKTraversingDelegate> parent;
    id<MKTraversingDelegate> root = self;
    
    while ((parent = [root parent]))
        root = parent;

    visitor(root, &stop);
}

- (void)traverseChildren:(MKVisitor)visitor withSelf:(BOOL)withSelf
{
    BOOL stop = NO;
    
    if (withSelf)
        visitor(self, &stop);
    
    if (stop == NO)
        for (id<MKTraversing> child in [self children])
        {
            visitor(child, &stop);
            if (stop) break;
        }
}

- (void)traverseAncestors:(MKVisitor)visitor withSelf:(BOOL)withSelf
{
    BOOL stop = NO;
    
    if (withSelf)
        visitor(self, &stop);
    
    id<MKTraversingDelegate> parent = self;
    
    while (parent && stop == NO)
    {
        parent = [parent parent];
        if (parent)
            visitor(parent, &stop);
    }
}

- (void)traverseDescendants:(MKVisitor)visitor withSelf:(BOOL)withSelf
{
    if (withSelf)
        [MKTraversal levelOrder:self visitor:visitor];
    else
    {
        [MKTraversal levelOrder:self visitor:^(id<MKTraversing> node, BOOL *stop) {
            if (node != self)
                visitor(node, stop);
        }];
    }
}

- (void)traverseDescendantsReverse:(MKVisitor)visitor withSelf:(BOOL)withSelf
{
    if (withSelf)
        [MKTraversal reverseLevelOrder:self visitor:visitor];
    else
    {
        [MKTraversal reverseLevelOrder:self visitor:^(id<MKTraversing> node, BOOL *stop) {
            if (node != self)
                visitor(node, stop);
        }];
    }
}

- (void)traverseParentSiblingOrSelf:(MKVisitor)visitor withSelf:(BOOL)withSelf
                          andParent:(BOOL)withParent
{
    BOOL stop = NO;
    
    if (withSelf)
        visitor(self, &stop);
    
    if (stop == NO)
    {
        id<MKTraversingDelegate> parent = self.parent;
        for (id<MKTraversing> sibling in [parent children])
        {
            if (sibling != self)
            {
                visitor(sibling, &stop);
                if (stop) break;
            }
        }
        if (withParent && stop == NO)
            visitor(parent, &stop);
    }
}

#pragma mark - MKTraversingAxis validation

NSString * const FormatAxisName[] = {
    [MKTraversingAxisSelf]                    = @"MKTraversingAxisSelf",
    [MKTraversingAxisRoot]                    = @"MKTraversingAxisRoot",
    [MKTraversingAxisChild]                   = @"MKTraversingAxisChild",
    [MKTraversingAxisSibling]                 = @"MKTraversingAxisSibling",
    [MKTraversingAxisAncestor]                = @"MKTraversingAxisAncestor",
    [MKTraversingAxisDescendant]              = @"MKTraversingAxisDescendant",
    [MKTraversingAxisDescendantReverse]       = @"MKTraversingAxisDescendantReverse",
    [MKTraversingAxisChildOrSelf]             = @"MKTraversingAxisChildOrSelf",
    [MKTraversingAxisSiblingOrSelf]           = @"MKTraversingAxisSiblingOrSelf",
    [MKTraversingAxisAncestorOrSelf]          = @"MKTraversingAxisAncestorOrSelf",
    [MKTraversingAxisDescendantOrSelf]        = @"MKTraversingAxisDescendantOrSelf",
    [MKTraversingAxisDescendantOrSelfReverse] = @"MKTraversingAxisDescendantOrSelfReverse",
    [MKTraversingAxisParentSiblingOrSelf]     = @"MKTraversingAxisParentSiblingOrSelf"
};

- (BOOL)validateAxis:(MKTraversingAxes)axis require:(BOOL)require
{
    BOOL parentRequired   = NO;
    BOOL childrenRequired = NO;
    
    switch (axis)
    {
        case MKTraversingAxisSelf:
            break;
            
        case MKTraversingAxisRoot:
        case MKTraversingAxisAncestor:
        case MKTraversingAxisAncestorOrSelf:
            parentRequired = YES;
            break;
            
        case MKTraversingAxisChild:
        case MKTraversingAxisChildOrSelf:
        case MKTraversingAxisDescendant:
        case MKTraversingAxisDescendantReverse:
        case MKTraversingAxisDescendantOrSelf:
        case MKTraversingAxisDescendantOrSelfReverse:
            childrenRequired = YES;
            break;

        case MKTraversingAxisSibling:
        case MKTraversingAxisSiblingOrSelf:
        case MKTraversingAxisParentSiblingOrSelf:
            parentRequired   = YES;
            childrenRequired = YES;
            break;
    }

    if (parentRequired && [self respondsToSelector:@selector(parent)] == NO)
    {
        if (require)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                    reason:[NSString stringWithFormat:@"Traversing axis %@ requires the target class "
                                                       "respond to the parent selector",
                                                        FormatAxisName[axis]]
                   userInfo:nil];
        return NO;
    }

    if (childrenRequired && [self respondsToSelector:@selector(children)] == NO)
    {
        if (require)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                    reason:[NSString stringWithFormat:@"Traversing axis %@ requires the target class "
                                                        "respond to the children selector",
                                                   FormatAxisName[axis]]

                  userInfo:nil];
        return NO;
    }
    
    return YES;
}

@end
