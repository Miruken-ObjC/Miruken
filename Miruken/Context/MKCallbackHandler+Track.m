//
//  MKDeferred+Context.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Track.h"
#import "MKCallbackHandler+Buffer.h"
#import "MKCallbackHandler+Context.h"
#import "MKContext+Subscribe.h"
#import "MKContext.h"
#import "MKCallbackHandlerFilter.h"
#import "NSObject+ResolvePromise.h"

@implementation MKCallbackHandler (Track)

- (instancetype)trackPromise
{
    MKContext *context = self.context;
    
    if (context == nil)
        @throw [NSException exceptionWithName:NSObjectNotAvailableException
                                       reason:@"Promises cannot be tracked without a context"
                                     userInfo:nil];
    
    return [MKCallbackHandlerFilter for:self
            filter:^(id callback, id<MKCallbackHandler> composer, BOOL(^proceed)()) {
                MKPromise promise;
                BOOL handled = proceed();
                if (handled && (promise = [callback effectivePromise]))
                {
                    if (context.state == MKContextStateActive)
                        [promise always:[context subscribeDidEnd:^(id<MKContext> context) {
                            [promise cancel];
                        }]];
                    else
                        [promise cancel];
                }
                return handled;
            }];
    
    return self;
}

@end
