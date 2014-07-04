//
//  MKAsyncResult_Subclassing.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncResult_Subclassing.h"
#import "MKDeferred.h"

@implementation MKAsyncResult
{
    NSValue          *_result;
    NSException      *_exception;
    NSInvocation     *_invocation;
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

- (MKPromise)promise
{
    return [_deferred promise];
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
    [self _completeForRepeat:NO];
}

- (void)repeat
{
    [self _completeForRepeat:YES];
}

- (void)_completeForRepeat:(BOOL)canRepeat
{
    if (self.isComplete)
        return;
    
    @try
    {
        [_invocation invoke];
        NSMethodSignature *signature = [_invocation methodSignature];
        NSUInteger         length    = [signature methodReturnLength];
        if (length > 0)
            _result = [self extractResultFromInvocation:_invocation];
        
        if (self.isComplete == NO)
        {
            if (canRepeat)
                [_deferred notify:_result];
            else
                [_deferred resolve:_result];
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
             _invocation = nil;
    }
}

- (id)extractResultFromInvocation:(NSInvocation *)invocation
{
    NSMethodSignature *signature = [_invocation methodSignature];
    NSUInteger         length    = [signature methodReturnLength];
    
    const char *returnType = [signature methodReturnType];
    if (strcmp(returnType, @encode(dispatch_block_t)) == 0)
    {
        __unsafe_unretained dispatch_block_t block;
        [_invocation getReturnValue:&block];
        if (block)
            block = (__bridge dispatch_block_t)Block_copy((__bridge void *)block);
        return [NSValue valueWithBytes:&block objCType:returnType];
    }
    else
    {
        void *buffer = (void *)malloc(length);
        [_invocation getReturnValue:buffer];
        return [NSValue valueWithBytes:buffer objCType:returnType];
    }
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
