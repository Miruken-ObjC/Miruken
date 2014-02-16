//
//  MKHandleMethod.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKHandleMethod.h"
#import "MKReadWriteLock.h"

#pragma mark - MKFindMethodSignature

static NSMutableDictionary  *methodSignatureCache;
static MKReadWriteLock        *lock;

@implementation MKFindMethodSignature

+ (void)initialize
{
    if (self == MKFindMethodSignature.class)
    {
        methodSignatureCache = [NSMutableDictionary new];
        lock                 = [MKReadWriteLock new];
    }
}

+ (instancetype)forSelector:(SEL)selector
{
    MKFindMethodSignature *findSignature = [MKFindMethodSignature new];
    findSignature->_selector           = selector;
    
    NSString *selectorKey              = NSStringFromSelector(selector);
    findSignature->_signature          = [methodSignatureCache objectForKey:selectorKey];
    
    if (findSignature->_signature == nil)
        [lock reading:^{
            findSignature->_signature = [methodSignatureCache objectForKey:selectorKey];
        }];
         
    return findSignature;
}

- (void)setSignature:(NSMethodSignature *)signature
{
    if ((_signature = signature))
    {
        NSString *selectorKey = NSStringFromSelector(_selector);
        [lock writing:^{
             [methodSignatureCache setObject:_signature forKey:selectorKey];
        }];
    }
}

@end

#pragma mark - MKHandleMethod

NSString * const CurrentHandleMethodKey = @"CurrentHandleMethod";
NSString * const HandledMethodKey       = @"HandledMethod";
NSString * const ComposerKey            = @"HandleMethodComposer";

@implementation MKHandleMethod
{
    MKHandleMethodBlock  _didInvoke;
    BOOL               _handled;
}

+ (instancetype)withInvocation:(NSInvocation *)invocation
{
    MKHandleMethod *invokeMethod = [self new];
    invokeMethod->_invocation    = invocation;
    return invokeMethod;
}

+ (instancetype)withInvocation:(NSInvocation *)invocation didInvoke:(MKHandleMethodBlock)didInvoke
{
    MKHandleMethod *invokeMethod = [MKHandleMethod withInvocation:invocation ];
    invokeMethod->_didInvoke     = didInvoke;
    return invokeMethod;
}

+ (instancetype)current
{
    return [[[NSThread currentThread] threadDictionary] valueForKey:CurrentHandleMethodKey];
}

+ (MKCallbackHandler *)composer
{
    return [[[NSThread currentThread] threadDictionary] valueForKey:ComposerKey];
}

- (MKHandleMethod *)setCurrent:(MKHandleMethod *)handleMethod
{
    NSMutableDictionary *threadLocal         = [[NSThread currentThread] threadDictionary];
    MKHandleMethod      *currentHandleMethod = [threadLocal valueForKey:CurrentHandleMethodKey];
    
    if (handleMethod)
        [threadLocal setValue:handleMethod forKey:CurrentHandleMethodKey];
    else
        [threadLocal removeObjectForKey:CurrentHandleMethodKey];
    
    return currentHandleMethod;
}

- (NSNumber *)setHandled:(NSNumber *)handled
{
    NSMutableDictionary *threadLocal    = [[NSThread currentThread] threadDictionary];
    NSNumber            *currentHandled = [threadLocal valueForKey:HandledMethodKey];
    
    if (handled)
        [threadLocal setValue:handled forKey:HandledMethodKey];
    else
        [threadLocal removeObjectForKey:HandledMethodKey];
    
    return currentHandled;
}

- (MKCallbackHandler *)setComposer:(MKCallbackHandler *)composer
{
    NSMutableDictionary *threadLocal     = [[NSThread currentThread] threadDictionary];
    MKCallbackHandler   *currentComposer = [threadLocal valueForKey:ComposerKey];
    
    if (composer)
        [threadLocal setValue:composer forKey:ComposerKey];
    else
        [threadLocal removeObjectForKey:ComposerKey];
    
    return currentComposer;
}

- (BOOL)invokeOn:(id)target composition:(MKCallbackHandler *)composer
{
    NSInvocation      *invocation = _invocation;
    NSMethodSignature *signature  = invocation.methodSignature;
    
    // Use original invocation until handled to determine return value.
    
    if (_handled)
    {
        NSUInteger argCount = signature.numberOfArguments;
        invocation          = [NSInvocation invocationWithMethodSignature:signature];

        for (int i = 0; i < argCount; ++i)
        {
            char buffer[sizeof(intmax_t)];
            [_invocation getArgument:(void *)&buffer atIndex:i];
            [invocation setArgument:(void *)&buffer atIndex:i];
        }
    }
    
    id                 oldCurrent  = [self setCurrent:self];
    NSNumber          *oldHandled  = [self setHandled:@(YES)];
    MKCallbackHandler *oldComposer = [self setComposer:composer];
    
    @try
    {
        [invocation invokeWithTarget:target];
        if (_didInvoke)
            _didInvoke(invocation);
        
        BOOL handled = [[self setHandled:oldHandled] boolValue];
        if (handled) _handled = YES;
        return handled;
    }
    @finally
    {
        [self setComposer:oldComposer];
        [self setHandled:oldHandled];
        [self setCurrent:oldCurrent];
    }
}

- (void)notHandled
{
    [self setHandled:@(NO)];
}

@end