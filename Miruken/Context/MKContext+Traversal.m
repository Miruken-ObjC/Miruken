//
//  MKContext+Traversal.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/12/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKContext+Traversal.h"
#import "MKHandleMethod.h"
#import "MKDecorator.h"
#import "NSInvocation+Objects.h"
#import "MKMixin.h"

@interface MKContextTraversalTrampoline : NSProxy

- (id)initWithContext:(MKContext *)context axis:(MKTraversingAxes)axis;

@end

#pragma mark - Context Traversal Category

@implementation MKContext (MKContext_Traversal)

- (instancetype)SELF
{
    return [self traverseAxis:MKTraversingAxisSelf];
}

- (instancetype)root
{
    return [self traverseAxis:MKTraversingAxisRoot];
}

- (instancetype)child
{
    return [self traverseAxis:MKTraversingAxisChild];
}

- (instancetype)sibling
{
    return [self traverseAxis:MKTraversingAxisSibling];
}

- (instancetype)ancestor
{
    return [self traverseAxis:MKTraversingAxisAncestor];
}

- (instancetype)descendant
{
    return [self traverseAxis:MKTraversingAxisDescendant];
}

- (instancetype)descendantReverse
{
    return [self traverseAxis:MKTraversingAxisDescendantReverse];
}

- (instancetype)childOrSelf
{
    return [self traverseAxis:MKTraversingAxisChildOrSelf];
}

- (instancetype)siblingOrSelf
{
    return [self traverseAxis:MKTraversingAxisSiblingOrSelf];
}

- (instancetype)ancestorOrSelf
{
    return [self traverseAxis:MKTraversingAxisAncestorOrSelf];
}

- (instancetype)descendantOrSelf
{
    return [self traverseAxis:MKTraversingAxisDescendantOrSelf];
}

- (instancetype)descendantOrSelfReverse
{
    return [self traverseAxis:MKTraversingAxisDescendantOrSelfReverse];
}

- (instancetype)parentSiblingOrSelf
{
    return [self traverseAxis:MKTraversingAxisParentSiblingOrSelf];
}

- (instancetype)traverseAxis:(MKTraversingAxes)axis
{
    return (MKContext *) [[MKContextTraversalTrampoline alloc] initWithContext:self axis:axis];
}

@end

#pragma mark - Context Traversal Trampoline

@implementation MKContextTraversalTrampoline
{
    MKContext         *_context;
    MKTraversingAxes _axis;
}

+ (void)initialize
{
    if (self == MKContextTraversalTrampoline.class)
        [MKMixin from:MKCallbackHandler.class into:self];
}

- (id)initWithContext:(MKContext *)context axis:(MKTraversingAxes)axis
{
    _context = context;
    _axis    = axis;
    return self;
}

- (BOOL)handle:(id)callback
{
    return [_context handle:callback axis:_axis];
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy
{
    return [_context handle:callback greedy:greedy axis:_axis];
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if (composer == self)
        composer = _context;
    return [_context handle:callback greedy:greedy composition:composer axis:_axis];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = [_context methodSignatureForSelector:sel];
    if ([MKCallbackHandler isUnknownMethod:signature])
    {
        MKFindMethodSignature *findSignature = [MKFindMethodSignature forSelector:sel];
        if ([self handle:findSignature greedy:NO composition:_context])
            return findSignature.signature;
    }
    return [MKCallbackHandler isUnknownMethod:signature] ? nil : signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([_context respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:_context];
    }
    else
    {
        MKHandleMethod *invokeMethod = [MKHandleMethod withInvocation:invocation];
        if ([self handle:invokeMethod greedy:NO composition:_context] == NO)
            [_context doesNotRecognizeSelector:invocation.selector];
    }
    
    // Context replacement is made for the following scenarios
    //   1) Return value is the underlyng context
    //   2) Return value is decorating the underlying context
    
    if ([invocation returnsObject])
    {
        id result = [invocation objectReturnValue];
     
        if (result == _context)
        {
            [invocation setObjectReturnValue:self];
        }
        else if ([result respondsToSelector:@selector(decoratee)] &&
                 [result respondsToSelector:@selector(setDecoratee:)])
        {
            if ([result decoratee] == _context)
                [result setDecoratee:self];
        }
    }
}

@end