//
//  MKCallbackHandler+Recoverable.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/30/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Recoverable.h"
#import "MKCallbackHandlerFilter.h"
#import "NSObject+ResolvePromise.h"
#import "MKErrors.h"

@implementation MKCallbackHandler (Recoverable)

- (instancetype)recoverable
{
    return [self recoverableInContext:NULL];
}

- (instancetype)recoverableInContext:(void *)context
{
    return [MKCallbackHandlerFilter for:self
            filter:^(id callback, id<MKCallbackHandler> composer, BOOL(^proceed)()) {
                MKPromise promise = nil;
                @try {
                    BOOL handled = proceed();
                    if (handled && (promise = [callback effectivePromise]))
                    {
                        __block id    failureReason  = nil;
                        __block BOOL *failureHandled = nil;
                        [[promise fail:^(id reason, BOOL *handled) {
                            failureReason  = reason;
                            failureHandled = handled;
                        }]
                        always:^{
                            if (failureHandled != nil && *failureHandled == NO)
                                [MKErrors(composer) handleFailure:failureReason context:context];
                            failureReason = nil;
                        }];
                    }
                    return handled;
                }
                @catch (id exception) {
                    [MKErrors(composer) handleFailure:exception context:context];
                }
            }];
}

@end
