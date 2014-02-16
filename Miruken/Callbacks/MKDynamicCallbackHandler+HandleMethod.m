//
//  DynamicCallbackHandler+HandleMethod.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDynamicCallbackHandler+HandleMethod.h"
#import "MKHandleMethod.h"

@implementation MKDynamicCallbackHandler (MKDynamicCallbackHandler_HandleMethod)

- (BOOL)handleMKHandleMethod:(MKHandleMethod *)handleMethod composition:(MKCallbackHandler *)composer
{
    SEL selector = handleMethod.invocation.selector;
    
    if (self.delegate && [self.delegate respondsToSelector:selector])
        return [handleMethod invokeOn:self.delegate composition:composer];
    
    if ([self respondsToSelector:handleMethod.invocation.selector])
        return [handleMethod invokeOn:self composition:composer];
    
    return NO;
}

- (BOOL)handleMKFindMethodSignature:(MKFindMethodSignature *)findSignature
{
    if (self.delegate)
        findSignature.signature = [self.delegate methodSignatureForSelector:findSignature.selector];
    
    if (findSignature.signature == nil)
    {
        // Make sure we call [NSObject methodSignatureForSelector] so we don't cycle
        findSignature.signature  = [self baseMethodSignatureForSelector:findSignature.selector];
    }
    
    return findSignature.signature != nil;
}

@end
