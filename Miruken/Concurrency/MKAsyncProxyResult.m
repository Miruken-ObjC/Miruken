//
//  MKAsyncProxyResultm
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncProxyResult.h"
#import "MKDeferred.h"
#import "NSInvocation+Objects.h"

@implementation MKAsyncProxyResult
{
    id                _result;
    NSException      *_exception;
    NSInvocation     *_invocation;
    MKDeferred       *_deferred;
    NSArray          *_blockArguments;
}

- (id)initWithInvocation:(NSInvocation *)invocation
{
    _invocation     = invocation;
    _deferred       = [MKDeferred new];
    _blockArguments = [MKAsyncResult copyBlockArguments:invocation];
    return self;
}

- (BOOL)isComplete
{
    return _deferred.state != MKPromiseStatePending;
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
    if (_deferred.state != MKPromiseStatePending)
        return;

    @try
    {
        [_invocation invoke];
        _result = [_invocation objectReturnValue];
        if (canRetry)
            [_deferred notify:_result];
        else
            [_deferred resolve:_result];
    }
    @catch (NSException *exception)
    {
        _exception = exception;
        [_deferred reject:_exception];
    }
    @finally
    {
        if (canRetry == NO)
            _invocation = nil;
    }
}

- (id)result
{
    [_deferred wait];
    
    if (_exception)
    {
        [_exception raise];
        return nil;
    }
    
    return _result;
}

- (id<MKPromise>)promise
{
    return [_deferred promise];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if (_deferred.state == MKPromiseStatePending)
        [self result];
    return _result
         ? [_result methodSignatureForSelector:aSelector]
         : [NSMethodSignature signatureWithObjCTypes:"v@"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if (_deferred.state == MKPromiseStatePending)
        [self result];
    if (_result)
        [anInvocation invokeWithTarget:_result];
}

- (void)dealloc
{
    [MKAsyncResult releaseBlockArguments:_blockArguments];
}

@end
