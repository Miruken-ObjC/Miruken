//
//  MKCallbackHandler+Context.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/21/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Context.h"
#import "MKCallbackHandler+Resolvers.h"

@implementation MKCallbackHandler (MKCallbackHandler_Context)

- (MKContext *)context
{
    if ([self isKindOfClass:MKContext.class])
        return (MKContext *)self;
    
    MKContext *context = nil;
    [self tryGetClass:MKContext.class into:&context];
    return context;
}

@end
