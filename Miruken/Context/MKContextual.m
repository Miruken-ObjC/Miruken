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
#import "MKMixingIn.h"
#import <objc/runtime.h>

#pragma mark - MKContextual

@implementation MKContextual

+ (void)initialize
{
    if (self == MKContextual.class)
        [MKContextualMixin mixInto:self];
}

@end

#pragma mark - ContextualMixin methods

@interface MKContextualMixin () <MKContextual>
@end

@implementation MKContextualMixin

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
        
        [currentContext removeHandler:self];
        [context addHandler:self];
        
        if ([self respondsToSelector:@selector(contextChanged:)])
            [self contextChanged:context];
    }
}

- (BOOL)isActiveContext
{
    MKContext *currentContext = self.context;
    return currentContext && (currentContext.state == MKContextStateActive);
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

@end
