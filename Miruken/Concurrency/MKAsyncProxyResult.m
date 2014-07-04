//
//  MKAsyncProxyResultm
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncProxyResult.h"
#import "MKDeferred.h"
#import "MKAsyncResult_Subclassing.h"
#import "NSInvocation+Objects.h"
#import "MKDeferred+Await.h"
#import "EXTScope.h"

@implementation MKAsyncProxyResult
{
    id                _result;
    NSException      *_exception;
    NSInvocation     *_invocation;
    MKDeferred       *_deferred;
    MKDeferred       *_await;
    NSArray          *_blockArguments;
}

- (id)initWithInvocation:(NSInvocation *)invocation
{
    _invocation     = invocation;
    _deferred       = [MKDeferred new];
    _await          = [MKDeferred new];
    _blockArguments = [MKAsyncResult copyBlockArguments:invocation];
    
    @weakify(self)
    [_deferred cancel:^{ @strongify(self); [self cancelled]; }];
    [_await cancel:^{ @strongify(self); [self cancelled]; }];
    return self;
}

- (MKPromise)promise
{
    return [_deferred promise];
}

- (BOOL)isComplete
{
    return _deferred.state != MKPromiseStatePending;
}

- (void)complete
{
    [self _completeForRepeat:NO];
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

- (void)repeat
{
    [self _completeForRepeat:YES];
}

- (void)_completeForRepeat:(BOOL)canRepeat
{
    if (self.isComplete)
        return;

    NSMutableDictionary *threadLocal;
    MKDeferred          *currentAwait;
    
    if (canRepeat == NO)
    {
        threadLocal  = [[NSThread currentThread] threadDictionary];
        currentAwait = [threadLocal valueForKey:kDeferredAwaitKey];
        [threadLocal setValue:_await forKey:kDeferredAwaitKey];
    }
    
    @try
    {
        NSInvocation *invocation = _invocation;
        
        [invocation invoke];
        _result = [invocation objectReturnValue];
        
        if (self.isComplete == NO)
        {
            if (canRepeat)
                [_deferred notify:_result];
            else
            {
                if ([_result conformsToProtocol:@protocol(MKPromise)])
                    [_await connectPromise:_result];
                [_deferred resolve:_result];
            }
        }
    }
    @catch (NSException *exception)
    {
        _exception = exception;
        if (self.isComplete == NO)
            [_deferred reject:_exception];
    }
    @finally
    {
        if (canRepeat == NO)
        {
            if (currentAwait)
                [threadLocal setValue:currentAwait forKey:kDeferredAwaitKey];
            else
                [threadLocal removeObjectForKey:kDeferredAwaitKey];
            _invocation = nil;
        }
    }
}

- (void)cancelled
{
    [_await cancel];
    [_deferred cancel];
    _invocation = nil;
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
