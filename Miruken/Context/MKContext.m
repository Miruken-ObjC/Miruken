//
//  MKContext.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/15/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContext.h"
#import "MKContextObserver.h"
#import "MKOnDemandOutCallbackHandler.h"
#import "MKHandleGreedy.h"
#import "MKTraversingMixin.h"
#import "MKWeakCell.h"
#import "MirukenCallbacks.h"
#import "MKMixingIn.h"
#import "EXTScope.h"

@interface MKContext() <MKTraversingDelegate>
@end

@implementation MKContext
{
    MKWeakCell           *_children;
    MKWeakCell           *_subscriptions;
    NSMutableArray       *_retainedSubscriptions;
    MKContextUnsubscribe  _unsubscribeFromParent;
}

@synthesize parent = _parent;
@synthesize state  = _state;

+ (void)initialize
{
    if (self == MKContext.class)
        [MKTraversingMixin mixInto:self];
}

- (MKContext *)init
{
    if (self = [super init])
    {
        @weakify(self);
        [self addHandler:[MKOnDemandOutCallbackHandler
                          providedBy:^(id composer) { return self; }
                          when:^(Class class) {
                              @strongify(self);
                              return [self isKindOfClass:class];
                          }]
         ];
    }
    return self;
}

- (BOOL)hasChildren
{
    return _children != nil;
}

- (MKContext *)rootContext
{
    MKContext *root = self;
    
    while (root && root.parent)
        root = root.parent;

    return root;
}

- (id<NSFastEnumeration>)children
{
    return _children;
}

- (instancetype)add:(id)object
{
    [self addHandler:[object toCallbackHandler]];
    return self;
}

- (instancetype)newChildContext
{
    [self _ensureActive];
    
    MKContext *childContext = [self.class new];
    childContext.parent     = self;
    
    if (_children == nil)
        _children = [MKWeakCell cons:childContext];
    else
        _children = [_children add:childContext];
    
    return childContext;
}

- (void)removeChildContext:(MKContext *)childContext
{
    _children = [_children remove:childContext];
}

- (void)setParent:(MKContext *)parent
{
    [self _ensureActive];
    
    if (_unsubscribeFromParent)
    {
        _unsubscribeFromParent();
        _unsubscribeFromParent = nil;
    }
    
    if (_parent)
        [_parent removeChildContext:self];
    
    if ((_parent = parent))
    {
        @weakify(self);
        _unsubscribeFromParent =
            [parent subscribe:[MKContextObserver contextWillEnd:^(id<MKContext> ctx)
            {
                @strongify(self);
                [self end];
            } didEnd:nil]];
    }
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    BOOL handled = [super handle:callback greedy:greedy composition:composer];
    if (handled && greedy == NO)
        return handled;
    if (_parent != nil)
        handled = handled
        | [_parent handle:callback greedy:greedy composition:composer];
    return handled;
}

- (BOOL)handle:(id)callback axis:(MKTraversingAxes)axis
{
    BOOL greedy = [callback conformsToProtocol:@protocol(MKHandleGreedy)];
    return [self handle:callback greedy:greedy composition:self axis:axis];
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy axis:(MKTraversingAxes)axis
{
     return [self handle:callback greedy:greedy composition:self axis:axis];
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
          axis:(MKTraversingAxes)axis
{
    if (axis == MKTraversingAxisSelf)
        return [super handle:callback greedy:greedy composition:composer];
    
    __block BOOL handled = NO;
    
    [self traverse:^(MKContext *node, BOOL *stop) {
        handled = handled
        | [node handle:callback greedy:greedy composition:composer axis:MKTraversingAxisSelf];
        *stop = handled && greedy == NO;
    } axis:axis];
    
    return handled;
}

- (instancetype)unwindToRootContext
{
    MKContext *current = self;
    
    while (current) {
        if (current.parent == nil)
        {
            [current unwind];
            return current;
        }
        current = current.parent;
    }
    
    return nil;
}

- (void)unwind
{
    for (id<MKContext> child in self.children)
        [child end];
}

#pragma mark - Notification

- (void)unsubscribe:(id<MKContextObserver>)observer
{
    _subscriptions = [_subscriptions remove:observer];
    [_retainedSubscriptions removeObject:observer];
}

- (MKContextUnsubscribe)subscribe:(id<MKContextObserver>)observer
{
    return [self subscribe:observer retain:NO];
}

- (MKContextUnsubscribe)subscribe:(id<MKContextObserver>)observer retain:(BOOL)retain
{
    [self _ensureActive];
    
    if (observer == nil)
        @throw [NSException exceptionWithName: NSInvalidArgumentException
                                       reason: @"observer cannot be nil"
                                     userInfo: nil];

    if (retain == NO)
    {
        if (_subscriptions == nil)
            _subscriptions = [MKWeakCell cons:observer];
        else
            _subscriptions = [_subscriptions add:observer];
    }
    else
    {
        if (_retainedSubscriptions == nil)
            _retainedSubscriptions = [NSMutableArray arrayWithObject:observer];
        else
            [_retainedSubscriptions addObject:observer];
    }
    
    @weakify(self);
    return ^{ @strongify(self); [self unsubscribe:observer]; };
}

- (void)_notifyWillEnd:(BOOL)willEnd
{
    for (id<MKContextObserver> observer in _subscriptions)
    {
        if (willEnd)
        {
            if ([observer respondsToSelector:@selector(contextWillEnd:)])
                [observer contextWillEnd:self];
        }
        else if ([observer respondsToSelector:@selector(contextDidEnd:)])
             [observer contextDidEnd:self];
    }
    
    for (id<MKContextObserver> observer in [_retainedSubscriptions copy])
    {
        if (willEnd)
        {
            if ([observer respondsToSelector:@selector(contextWillEnd:)])
                [observer contextWillEnd:self];
        }
        else if ([observer respondsToSelector:@selector(contextDidEnd:)])
            [observer contextDidEnd:self];
    }
}

- (void)_notifyChild:(MKContext *)child willEnd:(BOOL)willEnd
{
    for (id<MKContextObserver> observer in _subscriptions)
    {
        if (willEnd)
        {
            if ([observer respondsToSelector:@selector(childContextWillEnd:)])
                [observer childContextWillEnd:child];
        }
        else if ([observer respondsToSelector:@selector(childContextDidEnd:)])
            [observer childContextDidEnd:child];
    }
    
    for (id<MKContextObserver> observer in [_retainedSubscriptions copy])
    {
        if (willEnd)
        {
            if ([observer respondsToSelector:@selector(childContextWillEnd:)])
                [observer childContextWillEnd:child];
        }
        else if ([observer respondsToSelector:@selector(childContextDidEnd:)])
            [observer childContextDidEnd:child];
    }
}

- (void)end
{
    if (_state == MKContextStateActive)
    {
        // Children are maintained in a weak list so keep alive until end has finished
        MKContext *keepAlive = self;
        
        _state = MKContextStateEnding;
        [self _notifyWillEnd:YES];
        if (_parent)
            [_parent _notifyChild:self willEnd:YES];
        _state = MKContextStateEnded;
        if (_parent)
        {
            [_parent removeChildContext:self];
            [_parent _notifyChild:self willEnd:NO];
        }
        [self _notifyWillEnd:NO];
        _retainedSubscriptions = nil;
        _subscriptions         = nil;
        keepAlive              = nil;
    }
}

- (void)_ensureActive
{
    if (_state != MKContextStateActive)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"context has already ended"
                                     userInfo:nil];
}

- (void)dealloc
{    
    [self end];
    
    _children              = nil;
    _subscriptions         = nil;
    _retainedSubscriptions = nil;
}

@end
