//
//  DynamicCallbackHandler+CallbackReceiver.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDynamicCallbackHandler+CallbackReceiver.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"
#import "NSInvocation+Objects.h"

@implementation MKDynamicCallbackHandler (MKDynamicCallbackHandler_CallbackReceiver)

- (BOOL)handleMKObjectCallbackReceiver:(MKObjectCallbackReceiver *)receiver
                           composition:(id<MKCallbackHandler>)composer
{
    NSString *specifier = NSStringFromClass(receiver.forClass);
    
    BOOL handled
        = receiver.object
        ? (self.delegate && [self _handleCallback:specifier receive:receiver
                                     composition:composer target:self.delegate])
            || [self _handleCallback:specifier receive:receiver composition:composer target:self]
        : (self.delegate && [self _provideCallback:specifier receive:receiver
                                      composition:composer target:self.delegate])
            || [self _provideCallback:specifier receive:receiver composition:composer target:self];
    
    return handled
        || (self.delegate && [receiver tryResolve:self.delegate])
        || [receiver tryResolve:self];
}

- (BOOL)handleMKProtocolCallbackReceiver:(MKProtocolCallbackReceiver *)receiver
                             composition:(id<MKCallbackHandler>)composer
{
    BOOL handled
        = (self.delegate && [self _provideCallback:NSStringFromProtocol(receiver.forProtocol)
                                          receive:receiver composition:composer target:self.delegate])
       || [self _provideCallback:NSStringFromProtocol(receiver.forProtocol) receive:receiver
                    composition:composer target:self];
    
    return handled
        || (self.delegate && [receiver tryResolve:self.delegate])
        || [receiver tryResolve:self];
}

#pragma mark - Callback receiver conventions

- (BOOL)_handleCallback:(NSString *)specifier receive:(id<MKCallbackReceiver>)receiver
            composition:(id<MKCallbackHandler>)composer target:(id)target
{
    BOOL passComposer = NO;
    
    SEL selector = [self resolveNamedSelector:
                    [NSString stringWithFormat:@"handle%@:", specifier] target:target];
    
    if (selector == nil)
    {
        selector = [self resolveNamedSelector:
                    [NSString stringWithFormat:@"handle%@:composition:", specifier] target:target];
        
        if (selector != nil)
            passComposer = YES;
        else
            return NO;
    }
    
    NSInteger          argIndex   = 2;
    id                 callback   = receiver.object;
    NSMethodSignature *signature  = [target methodSignatureForSelector:selector];
    NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setSelector:selector];
    [invocation setArgument:&callback atIndex:argIndex++];
        
    if (passComposer)
        [invocation setArgument:&composer atIndex:argIndex++];
    
    BOOL handled = YES;
    [invocation invokeWithTarget:target];
    
    if (strcmp([signature methodReturnType], @encode(BOOL)) == 0)
    {
        [invocation getReturnValue:&handled];
        return handled && [receiver tryResolve:callback];
    }
    else if (strcmp([signature methodReturnType], @encode(id)) == 0)
    {
        id result = [invocation objectReturnValue];
        if ([result conformsToProtocol:@protocol(MKPromise)])
        {
            if (result != receiver)
            {
                [[[((MKPromise)result) done:^(id result) {
                        [receiver resolve:result];
                    }]
                    fail:^(id reason, BOOL *failureHandled) {
                        [receiver reject:reason];
                        *failureHandled = YES;
                    }]
                  cancel:^{
                        [receiver cancel];
                }];
                
                [receiver cancel:^{ [result cancel]; }];
            }
        }
        else
            return [receiver tryResolve:result];
    }
    
    return handled;
}

- (BOOL)_provideCallback:(NSString *)specifier receive:(id<MKCallbackReceiver>)receiver
             composition:(id<MKCallbackHandler>)composer target:(id)target
{
    BOOL passComposer = NO;
    
    SEL selector = [self resolveNamedSelector:
                    [NSString stringWithFormat:@"provide%@", specifier] target:target];
    
    if (selector == nil)
    {
        selector = [self resolveNamedSelector:
                    [NSString stringWithFormat:@"provide%@:", specifier] target:target];
            
        if (selector != nil)
            passComposer = YES;
        else
            return NO;
    }
    
    NSInteger          argIndex   = 2;
    NSMethodSignature *signature  = [target methodSignatureForSelector:selector];
    NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setSelector:selector];
        
    if (passComposer)
        [invocation setArgument:&composer atIndex:argIndex++];
    
    [invocation invokeWithTarget:target];
    
    id result = [invocation objectReturnValue];
    
    if ([result conformsToProtocol:@protocol(MKPromise)])
    {
        if (result != receiver)
        {
            [[[((MKPromise)result) done:^(id result) {
                  [receiver resolve:result];
               }]
               fail:^(id reason, BOOL *failureHandled) {
                  [receiver reject:reason];
                  *failureHandled = YES;
               }]
            cancel:^{
                  [receiver cancel];
            }];
            
            [receiver cancel:^{ [result cancel]; }];
        }
        return YES;
    }
    else
        return result && [receiver tryResolve:result];
}

@end
