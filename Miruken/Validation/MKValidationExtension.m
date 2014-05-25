//
//  MKValidationExtension.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/24/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKValidationExtension.h"
#import "MKValidationResult.h"

@implementation MKValidationExtension

#pragma mark - Validation conventions

- (BOOL)handleMKValidationResult:(MKValidationResult *)validation composition:(id<MKCallbackHandler>)composer
{
    NSString *specifier = NSStringFromClass([validation.target class]);
    
    return
        (self.handler.delegate && [self handleMKValidationResult:specifier validation:validation
                                                     composition:composer target:self.handler.delegate])
     || [self handleMKValidationResult:specifier validation:validation composition:composer
                                target:self.handler];
}

- (BOOL)handleMKValidationResult:(NSString *)specifier validation:(MKValidationResult *)validation
                     composition:(id<MKCallbackHandler>)composer target:(id)target
{
    BOOL passObject   = YES;
    BOOL passComposer = NO;
    
    SEL selector = [self.handler resolveNamedSelector:
                    [NSString stringWithFormat:@"validate%@:validation:", specifier] target:target];
    
    if (selector == nil)
    {
        selector = [self.handler resolveNamedSelector:
                    [NSString stringWithFormat:@"validate%@:validation:composition:", specifier]
                                       target:target];
        if (selector)
            passComposer = YES;
    }
    
    if (selector == nil)
    {
        passObject = NO;
        selector   = [self.handler resolveNamedSelector:@"validateUnknown:" target:target];
        
        if (selector == nil)
        {
            selector = [self.handler resolveNamedSelector:@"validateUnknown:composition:" target:target];
            if (selector)
                passComposer = YES;
            else
                return NO;
        }
    }
    
    NSInteger          argIndex   = 2;
    NSMethodSignature *signature  = [target methodSignatureForSelector:selector];
    NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setSelector:selector];
    if (passObject)
    {
        id target = validation.target;
        [invocation setArgument:&target atIndex:argIndex++];
    }
    [invocation setArgument:&validation atIndex:argIndex++];
    
    if (passComposer)
        [invocation setArgument:&composer atIndex:argIndex++];
    
    BOOL handled = YES;
    [invocation invokeWithTarget:target];
    
    if (strcmp([signature methodReturnType], @encode(BOOL)) == 0)
        [invocation getReturnValue:&handled];
    
    return handled;
}

@end
