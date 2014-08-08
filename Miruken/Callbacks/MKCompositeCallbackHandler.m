//
//  MKCompositeCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCompositeCallbackHandler.h"
#import "MKCascadeCallbackHandler.h"
#import "MKDynamicCallbackHandler.h"

@implementation MKCompositeCallbackHandler
{
    NSMutableArray *_handlers;
}

+ (instancetype)withHandler:(id)handler
{
    MKCompositeCallbackHandler *composite = [self new];
    [composite addHandler:handler];
    return composite;
}

+ (instancetype)withHandlers:(id)handler, ...
{
    va_list args;
    va_start(args, handler);
    MKCompositeCallbackHandler *composite = [self new];
    for (id<MKCallbackHandler> arg = handler; arg != nil; arg = va_arg(args, id<MKCallbackHandler>))
        [composite addHandler:arg];
    va_end(args);
    return composite;    
}

- (id)effectiveCallbackHandler:(id)handler
{
    return [handler conformsToProtocol:@protocol(MKCallbackHandler)]
         ? handler
         : [MKDynamicCallbackHandler delegateTo:handler];
}

- (instancetype)addHandler:(id)handler
{
    if (handler == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"handler cannot be nil"
                                     userInfo:nil];    
    }
 
    handler = [self effectiveCallbackHandler:handler];
    
    if (_handlers == nil)
        _handlers = [NSMutableArray arrayWithObject:handler];
    else
        [_handlers addObject:handler];

    return self;
}

- (instancetype)addHandlers:(id)handler, ...
{
    va_list args;
    va_start(args, handler);
    for (id<MKCallbackHandler> arg = handler; arg != nil; arg = va_arg(args, id<MKCallbackHandler>))
        [self addHandler:arg];
    va_end(args);
    return self;
}

- (instancetype)insertHandler:(id)handler atIndex:(NSUInteger)index
{
    if (_handlers == nil)
        _handlers = [NSMutableArray new];
    [_handlers insertObject:[self effectiveCallbackHandler:handler] atIndex:index];
    return self;
}

- (instancetype)insertHandler:(id)handler afterClass:(Class)exactClass
{
    handler = [self effectiveCallbackHandler:handler];
    if (_handlers == nil)
         _handlers = [NSMutableArray new];
    else
        for (NSUInteger index = 0; index < _handlers.count; ++index)
            if ([_handlers[index] isMemberOfClass:exactClass])
            {
                [_handlers insertObject:handler atIndex:index + 1];
                return self;
            }
    [_handlers addObject:handler];
    return self;
}

- (instancetype)insertHandler:(id)handler beforeClass:(Class)exactClass
{
    handler = [self effectiveCallbackHandler:handler];
    if (_handlers == nil)
         _handlers = [NSMutableArray new];
    else
        for (NSUInteger index = 0; index < _handlers.count; ++index)
            if ([_handlers[index] isMemberOfClass:exactClass])
            {
                [_handlers insertObject:handler atIndex:index];
                return self;
            }
    [_handlers addObject:handler];
    return self;
}

- (instancetype)replaceHandler:(id)handler forClass:(Class)exactClass
{
    if (_handlers)
        for (NSUInteger index = 0; index < _handlers.count; ++index)
            if ([_handlers[index] isMemberOfClass:exactClass])
            {
                _handlers[index] = [self effectiveCallbackHandler:handler];
                return self;
            }
    return self;
}

- (instancetype)removeHandler:(id)handler
{
    if (handler == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"handler cannot be nil"
                                     userInfo:nil];
    }

    if (_handlers == nil)
        return self;
    
    if ([handler conformsToProtocol:@protocol(MKCallbackHandler)])
    {
        [_handlers removeObject:handler];
        return self;
    }
    
    for (NSUInteger index = 0; index < _handlers.count; ++index)
    {
        id candidateHandler = _handlers[index];
        if ([candidateHandler isKindOfClass:MKDynamicCallbackHandler.class])
        {
            MKDynamicCallbackHandler *dynamicHandler = (MKDynamicCallbackHandler *)candidateHandler;
            if (dynamicHandler.delegate == handler)
            {
                [_handlers removeObjectAtIndex:index];
                return self;
            }
        }
    }

    return self;
}

- (instancetype)removeHandlers:(id)handler, ...
{
    va_list args;
    va_start(args, handler);
    for (id<MKCallbackHandler> arg = handler; arg != nil; arg = va_arg(args, id<MKCallbackHandler>))
        [self removeHandler:arg];
    va_end(args);
    return self;
}

- (instancetype)removeHandlerAtIndex:(NSUInteger)index
{
    [_handlers removeObjectAtIndex:index];
    return self;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id)composer
{
    BOOL handled = NO;
    if (_handlers) for (id<MKCallbackHandler> handler in [_handlers copy])
    {
        if ([handler handle:callback greedy:greedy composition:composer])
        {
            if (greedy == NO)
                return YES;
            handled = YES;
        }
    }
    return handled || [super handle:callback greedy:greedy composition:composer];
}

- (void)dealloc
{
    _handlers = nil;
}

@end
