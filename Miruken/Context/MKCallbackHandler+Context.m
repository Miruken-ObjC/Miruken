//
//  MKCallbackHandler+Context.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/21/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Context.h"
#import "MKCallbackHandler+Resolvers.h"
#import "MKCallbackHandler+Invocation.h"
#import "MKContext+Traversal.h"

@implementation MKCallbackHandler (MKCallbackHandler_Context)

- (MKContext *)context
{
    if ([self isKindOfClass:MKContext.class])
        return (MKContext *)self;
    
    MKContext *context = nil;
    [self tryGetClass:MKContext.class into:&context];
    return context;
}

- (id)forNotification
{
    MKCallbackHandler *composer = self;
    MKContext *context = composer.context;
    if (context)
        composer = [context descendantOrSelf];
    return [composer notify];
}

@end
