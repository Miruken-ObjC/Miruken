//
//  MKSynchronousResult.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKSynchronousResult.h"
#import "MKDeferred.h"
#include <pthread.h>

@implementation MKSynchronousResult
{
    NSInvocation   *_invocation;
    MKDeferred     *_deferred;
    NSArray        *_blockArguments;
}

- (id)initWithInvocation:(NSInvocation *)invocation copyBlockArguments:(BOOL)copyBlockArguments;
{
    if (self = [super init])
    {
        _invocation = invocation;
        _deferred   = [MKDeferred new];
        if (copyBlockArguments)
            _blockArguments = [MKAsyncResult copyBlockArguments:invocation];
    }
    return self;
}

- (BOOL)isComplete
{
    return _deferred.state != MKPromiseStatePending;
}

- (id)result
{
    return nil;
}

- (void)complete
{
    [self _completeForRetry:NO];
}

- (void)retry
{
    [self _completeForRetry:YES];
}

- (void)_completeForRetry:(BOOL)canRetry
{
    if (_deferred.state == MKPromiseStatePending)
    {
        [_invocation invoke];
        if (canRetry)
            [_deferred notify:nil];
        else
        {
            _invocation = nil;
            [_deferred resolve:nil];
        }
    }
}

- (id<MKPromise>)promise
{
    return [_deferred promise];
}

- (void)dealloc
{
    [MKAsyncResult releaseBlockArguments:_blockArguments];
}

@end
