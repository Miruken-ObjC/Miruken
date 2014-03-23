//
//  NSObject+Context.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+Context.h"
#import "MKContextualHelper.h"
#import "MKHandleMethod.h"

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
    
    @throw [NSException exceptionWithName:@"ContextNotAccepted"
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
