//
//  MKContext+Traversal.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/12/13.
//  Copyright (c) 2013 ZixCorp. All rights reserved.
//

#import "MKContext+Traversal.h"
#import "MKHandleMethod.h"
#import "MKDecorator.h"
#import "NSInvocation+Objects.h"
#import "MKMixin.h"

@interface ContextTraversalTrampoline : NSProxy

- (id)initWithContext:(MKContext *)context axis:(MKTraversingAxes)axis;

@end

#pragma mark - Context Traversal Category

@implementation MKContext (MKContext_Traversal)

- (instancetype)SELF
{
    return [self newContextTraversal:MKTraversingAxisSelf];
}

- (instancetype)root
{
    return [self newContextTraversal:MKTraversingAxisRoot];
}

- (instancetype)child
{
    return [self newContextTraversal:MKTraversingAxisChild];
}

- (instancetype)ancestor
{
    return [self newContextTraversal:MKTraversingAxisAncestor];
}

- (instancetype)descendant
{
    return [self newContextTraversal:MKTraversingAxisDescendant];
}

- (instancetype)childOrSelf
{
    return [self newContextTraversal:MKTraversingAxisChildOrSelf];
}

- (instancetype)ancestorOrSelf
{
    return [self newContextTraversal:MKTraversingAxisAncestorOrSelf];
}

- (instancetype)descendantOrSelf
{
    return [self newContextTraversal:MKTraversingAxisDescendantOrSelf];
}

- (instancetype)parentSiblingOrSelf
{
    return [self newContextTraversal:MKTraversingAxisParentSiblingOrSelf];
}

- (instancetype)newContextTraversal:(MKTraversingAxes)axis
{
    return (MKContext *) [[ContextTraversalTrampoline alloc]  initWithContext:self axis:axis];
}

@end

#pragma mark - Context Traversal Trampoline

@implementation ContextTraversalTrampoline
{
    MKContext         *_context;
    MKTraversingAxes _axis;
}

+ (void)initialize
{
    if (self == ContextTraversalTrampoline.class)
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
    return [_context handle:callback greedy:greedy composition:composer axis:_axis];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = [_context methodSignatureForSelector:sel];
    if ([MKCallbackHandler isUnknownMethod:signature])
    {
        MKFindMethodSignature *findSignature = [MKFindMethodSignature forSelector:sel];
        if ([self handle:findSignature greedy:NO composition:nil])
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
        if ([self handle:invokeMethod greedy:NO composition:nil] == NO)
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