//
//  MKCallbackHandler+Buffer.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/5/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Buffer.h"
#import "MKCallbackHandlerFilter.h"
#import "NSInvocation+Objects.h"
#import "NSObject+BuildPromise.h"
#import "MKHandleMethod.h"

@implementation MKCallbackHandler (MKCallbackHandler_Buffer)

- (instancetype)bufferPromise
{
    return [MKCallbackHandlerFilter for:self
            filter:^(id callback, id<MKCallbackHandler> composer, BOOL(^proceed)()) {
                BOOL handled = proceed();

                if (handled && [callback isKindOfClass:MKHandleMethod.class])
                {
                    NSInvocation *invocation = [((MKHandleMethod *)callback) invocation];
                    if ([invocation returnsObject])
                    {
                        id result = [invocation objectReturnValue];
                        if ([result conformsToProtocol:@protocol(MKPromise)])
                            [invocation setObjectReturnValue:[result buffer]];
                    }
                }
                
                return handled;
            }];
}

@end
