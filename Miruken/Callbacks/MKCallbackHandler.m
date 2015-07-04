//
//  MKCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/17/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKHandleGreedy.h"
#import "MKHandleMethod.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"
#import <objc/runtime.h>

static NSMethodSignature *unknownMethod;
static SEL NSObject_methodSignatureForSelectorSelctor;
static IMP NSObject_methodSignatureForSelectorIMP;

@implementation MKCallbackHandler

+ (void)load
{
    unknownMethod = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    NSObject_methodSignatureForSelectorSelctor = @selector(methodSignatureForSelector:);
    NSObject_methodSignatureForSelectorIMP     = class_getMethodImplementation
        (NSObject.class, NSObject_methodSignatureForSelectorSelctor);
}

- (BOOL)handle:(id)callback
{
    BOOL greedy = [callback conformsToProtocol:@protocol(MKHandleGreedy)];
    return [self handle:callback greedy:greedy composition:self];
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy
{
     return [self handle:callback greedy:greedy composition:self];
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(MKCallbackHandler *)composer
{
    if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
    {
        MKObjectCallbackReceiver *receiver = callback;
        return [receiver tryResolve:self];
    }
    else if ([callback isKindOfClass:MKProtocolCallbackReceiver.class])
    {
        MKProtocolCallbackReceiver *receiver = callback;
        return [receiver tryResolve:self];
    }
    return NO;
}

#pragma mark - Method call semantics

- (BOOL)dispatchInvocation:(NSInvocation*)anInvocation
{
    MKHandleMethod *invokeMethod = [MKHandleMethod withInvocation:anInvocation];
    return invokeMethod.invocation.methodSignature != unknownMethod
         ? [self handle:invokeMethod]
         : NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    __block NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (signature)
        return signature;
    
    MKFindMethodSignature *findSignature = [MKFindMethodSignature forSelector:aSelector];
    if ((signature = findSignature.signature))
        return signature;
    
    if ([self handle:findSignature])
        signature = findSignature.signature;
    
    return signature ? signature : unknownMethod;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self dispatchInvocation:anInvocation] == NO)
        [self doesNotRecognizeSelector:anInvocation.selector];
}

- (NSMethodSignature *)baseMethodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = NSObject_methodSignatureForSelectorIMP
        (self, NSObject_methodSignatureForSelectorSelctor, aSelector);
    return signature;}

+ (BOOL)isUnknownMethod:(NSMethodSignature *)methodSignature;
{
    return methodSignature == nil || methodSignature == unknownMethod;
}

@end