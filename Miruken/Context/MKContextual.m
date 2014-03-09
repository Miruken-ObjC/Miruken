//
//  MKContextual.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/15/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContextual.h"
#import "MKDynamicCallbackHandler.h"
#import "MKContextualHelper.h"
#import "MKHandleMethod.h"
#import "MKMixin.h"
#import <objc/runtime.h>

#pragma mark - MKContextual

@implementation MKContextual

+ (void)initialize
{
    if (self == MKContextual.class)
        [self mixinFrom:MKContextualMixin.class];
}

@end

#pragma mark - ContextualMixin methods

@interface MKContextualMixin () <MKContextual>
@end

@implementation MKContextualMixin

+ (void)mixInto:(Class)class
{
    [class mixinFrom:self];
}

- (MKContext *)context
{
    return objc_getAssociatedObject(self, @selector(context));
}

- (void)setContext:(MKContext *)context
{
    MKContext *currentContext = self.context;
    
    if (currentContext != context)
    {
        objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN);
        
        // Allow callbacks to be processed by the host if not already a CallbackHandler
        
        MKCallbackHandler *handler;
        
        if (context)
        {
            if ([self conformsToProtocol:@protocol(MKCallbackHandler)])
                handler = (MKCallbackHandler *)self;
            else
            {
                MKDynamicCallbackHandler *dynHandler = self.dynamicHandler;
                if (dynHandler == nil)
                {
                    dynHandler = [MKDynamicCallbackHandler delegateTo:self];
                    self.dynamicHandler = dynHandler;
                    handler    = dynHandler;
                }
            }
            [context addHandler:handler];
        }
        else
        {
            handler = [self conformsToProtocol:@protocol(MKCallbackHandler)]
                    ? (MKCallbackHandler *)self : self.dynamicHandler;
            
            if (handler)
                [currentContext removeHandler:handler];
        }
        
        if ([self respondsToSelector:@selector(contextChanged:)])
            [self contextChanged:context];
    }
}

- (BOOL)isActiveContext
{
    return [self.context state] == MKContextStateActive;
}

- (void)endContext
{
    [self.context end];
}

- (void)endContextWithObject:(id)object
{
    MKContext *context = self.context;
    if (object)
        [context add:object];
    [context end];
}

/**
  Included to easily allow endContext to be used as a target action in Interface Builder.
 */
- (void)endContext:(id)ignore
{
    [self.context end];
}

- (MKDynamicCallbackHandler *)dynamicHandler
{
    return objc_getAssociatedObject(self, @selector(dynamicHandler));
}

- (void)setDynamicHandler:(MKDynamicCallbackHandler *)handler
{
    objc_setAssociatedObject(self, @selector(dynamicHandler), handler, OBJC_ASSOCIATION_RETAIN);
}

@end

#pragma mark - NSObject_Context methods

@implementation NSObject (NSObject_Context)

+ (instancetype)allocInContext:(id)context
{
    MKContext *ctx = [self obtainContext:context makeChild:NO];
    return [self bindContext:ctx toObject:[self alloc]];
}

+ (instancetype)allocInChildContext:(id)context
{
    MKContext *ctx = [self obtainContext:context makeChild:YES];
    return [self bindContext:ctx toObject:[self alloc]];
}

+ (instancetype)newInContext:(id)context
{
    return [[self allocInContext:context] init];
}

+ (instancetype)newInChildContext:(id)context
{
    return [[self allocInChildContext:context] init];
}

+ (instancetype)obtainContext:(id)context makeChild:(BOOL)makeChild
{
    MKContext *ctx = [MKContextualHelper requireContext:context]; 
    return makeChild ? [ctx newChildContext] : ctx;
}

+ (id)bindContext:(MKContext *)context toObject:(id)object
{
    if ([object respondsToSelector:@selector(setContext:)])
    {        
        [object setContext:context];
        return object;
    }
    
    @throw [NSException
            exceptionWithName:@"ContextNotAccepted"
                       reason:@"The object does not accept an MKContext.  "
                               "Did you forget to conform to the MKContextual protocol?"
                     userInfo:nil];
}

- (MKCallbackHandler *)composer
{
    MKCallbackHandler *handleMethodComposer = [MKHandleMethod composer];
    if (handleMethodComposer)
        return handleMethodComposer;
    
    MKContext *context = [MKContextualHelper contextBoundTo:self];
    if (context)
        return context;
    
    if ([self isKindOfClass:MKCallbackHandler.class])
        return (MKCallbackHandler *)self;
    
    return nil;
}

@end