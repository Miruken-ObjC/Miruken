//
//  MKDynamicCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackReceiver.h"
#import "MKDynamicCallbackHandler.h"
#import "NSInvocation+Objects.h"
#import "MKHandleMethod.h"

@implementation MKDynamicCallbackHandler

+ (instancetype)delegateTo:(id)delegate
{
    MKDynamicCallbackHandler *handler = [MKDynamicCallbackHandler new];
    handler->_delegate                = delegate;
    return handler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    return callback &&
    ((_delegate && [self handle:callback greedy:greedy composition:composer target:_delegate])
     || [self handle:callback greedy:greedy composition:composer target:self]);
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer target:(id)target
{
    if (callback)
    {
        SEL selector = [self _findBestHandleSelector:callback target:target];
        return selector
        ? [self _invokeCallbackHandler:callback selector:selector composition:composer target:target]
        : [self handleUnknown:callback composition:composer target:target];
    }
    return NO;
}

- (BOOL)handleUnknown:(id)callback composition:(id<MKCallbackHandler>)composer target:(id)target
{
    SEL unknown = [self resolveNamedSelector:@"handleUnknownCallback:" target:target];
    if (unknown == nil)
        unknown = [self resolveNamedSelector:@"handleUnknownCallback:composition:" target:target];
    
    return unknown && [self _invokeCallbackHandler:callback selector:unknown
                                      composition:composer target:target];
}

- (BOOL)_invokeCallbackHandler:(id)callback selector:(SEL)selector
                   composition:(id<MKCallbackHandler>)composer target:(id)target
{
    BOOL handled                  = YES;
    NSMethodSignature *signature  = [target methodSignatureForSelector:selector];
    NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&callback atIndex:2];
    if (signature.numberOfArguments > 3)
        [invocation setArgument:&composer atIndex:3];
    [invocation invokeWithTarget:target];
    if (strcmp([signature methodReturnType], @encode(BOOL)) == 0)
        [invocation getReturnValue:&handled];
    return handled;
}

- (SEL)_findBestHandleSelector:(id)callback target:(id)target
{
    Class cbClass = [callback class];
    
    do
    {
        SEL selector = [self resolveNamedSelector:
                        [NSString stringWithFormat:@"handle%@:", NSStringFromClass(cbClass)]
                                           target:target];
        if (selector) return selector;
        
        selector     = [self resolveNamedSelector:
                        [NSString stringWithFormat:@"handle%@:composition:", NSStringFromClass(cbClass)]
                                           target:target];
        if (selector) return selector;
        
        cbClass      = cbClass.superclass;
    } while (cbClass);
    
    return nil;
}

- (SEL)resolveNamedSelector:(NSString *)selectorName target:(id)target
{
    SEL selector = NSSelectorFromString(selectorName);
    return [target respondsToSelector:selector] ? selector : nil;
}

@end
