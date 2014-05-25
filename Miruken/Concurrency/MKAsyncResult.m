//
//  MKAsyncResult.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncResult.h"
#import "MKDeferred.h"

@implementation MKAsyncResult
{
    NSValue          *_result;
    NSException      *_exception;
    NSInvocation     *_invocation;
    MKDeferred       *_deferred;
    NSArray          *_blockArguments;
}

- (id)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super init])
    {
        _invocation     = invocation;
        _deferred       = [MKDeferred new];
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
    [_deferred wait];

    if (_exception)
    {
        [_exception raise];
        return nil;
    }
    
    return _result;
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
        NSMethodSignature *signature = [_invocation methodSignature];
        NSUInteger         length    = [signature methodReturnLength];
        if (length > 0)
        {
            const char *returnType = [signature methodReturnType];
            if (strcmp(returnType, @encode(dispatch_block_t)) == 0)
            {
                __unsafe_unretained dispatch_block_t block;
                [_invocation getReturnValue:&block];
                if (block)
                    block = (__bridge dispatch_block_t)Block_copy((__bridge void*)block);
                _result = [NSValue valueWithBytes:&block objCType:returnType];
            }
            else
            {
                void *buffer = (void *)malloc(length);
                [_invocation getReturnValue:buffer];
                _result = [NSValue valueWithBytes:buffer objCType:returnType];
            }
        }
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

- (id<MKPromise>)promise
{
    return [_deferred promise];
}

+ (NSArray *)copyBlockArguments:(NSInvocation *)invocation;
{    
    NSMutableArray *blockArguments = nil;
    
    NSMethodSignature *methodSignature = invocation.methodSignature;
    
    for (int idx = 0; idx < methodSignature.numberOfArguments; ++idx)
    {
        const char *argType = [methodSignature getArgumentTypeAtIndex:idx];
        if (strcmp(argType, @encode(dispatch_block_t)) == 0)
        {
            __unsafe_unretained dispatch_block_t arg;
            [invocation getArgument:&arg atIndex:idx];
            if (arg)
            {
                arg = (__bridge dispatch_block_t)Block_copy((__bridge void*)arg);
                [invocation setArgument:&arg atIndex:idx];
                if (blockArguments == nil)
                    blockArguments = [NSMutableArray new];
                [blockArguments addObject:arg];
            }
        }
    }
    
    return blockArguments;
}

+ (void)releaseBlockArguments:(NSArray *)blockArguments
{
    if (blockArguments)
    {
        for (dispatch_block_t blockArg in blockArguments)
            Block_release((__bridge void*)blockArg);
    }
}

- (void)dealloc
{
    [MKAsyncResult releaseBlockArguments:_blockArguments];
}

@end
