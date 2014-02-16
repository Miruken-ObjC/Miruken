//
//  MKBufferedPromise.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/8/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKBufferedPromise.h"
#import "NSInvocation+Objects.h"
#import "EXTScope.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MKBufferedPromise
{
    NSMutableArray   *_done;
    NSMutableArray   *_fail;
    NSMutableArray   *_cancel;
    NSMutableArray   *_always;
    NSMutableArray   *_progress;
    NSMutableArray   *_buffer;
    id<MKPromise>       _promise;
    BOOL              _flushed;
}

+ (instancetype)bufferPromise:(id<MKPromise>)promise
{
    return [[MKBufferedPromise alloc] initWithPromise:promise];
}

- (id)initWithPromise:(id<MKPromise>)promise
{
    if (promise == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"MKPromise cannot be nil"
                                     userInfo:nil];

    if (self = [super init])
    {
        @weakify(self);
        _promise = [[[[[promise
            done:^(id result) {
                @strongify(self);
                [self buffer:^{ [self flushDone:result]; }];
            }]
            fail:^(id reason, BOOL *handled) {
                @strongify(self);
                [self buffer:^{ [self flushFail:reason handled:handled]; }];
            }]
          cancel:^{
                @strongify(self);
                [self buffer:^{ [self flushCancel]; }];
            }]
        progress:^(id progress, BOOL queued) {
                @strongify(self);
                [self buffer:^{ [self flushProgress:progress queued:queued]; }];
            }]
          always:^{
                @strongify(self);
                [self buffer:^{ [self flushAlways]; }];
            }];
        
        _buffer = [NSMutableArray new];
    }
    
    return self;
}

- (DeferredState)state
{
    return [_promise state];
}

- (BOOL)isPending
{
    return [_promise isPending];
}

- (BOOL)isResolved
{
    return [_promise isResolved];
}

- (BOOL)isRejected
{
    return [_promise isRejected];
}

- (BOOL)isCancelled
{
    return [_promise isCancelled];
}

- (id<MKBufferedPromise>)buffer
{
    return self;
}

- (void)flush
{
    if (_flushed == NO)
    {
        _flushed = YES;
        for (dispatch_block_t block in _buffer)
            block();
        [_buffer removeAllObjects];
    }
}

- (void)flushDone:(id)result
{
    if (_done)
        for (DoneCallback done in _done)
            done(result);
}

- (void)flushFail:(id)reason handled:(BOOL *)handled
{
    if (_fail)
        for (FailCallback fail in _fail)
            fail(reason, handled);
}

- (void)flushCancel
{
    if (_cancel)
        for (CancelCallback cancel in _cancel)
            cancel();
}

- (void)flushProgress:(id)progress queued:(BOOL)queued
{
    if (_progress)
        for (ProgressCallback notify in _progress)
            notify(progress, queued);
}

- (void)flushAlways
{
    if (_always)
        for (AlwaysCallback always in _always)
            always();    
}

- (void)buffer:(dispatch_block_t)block
{
    if (_flushed)
        block();
    else
        [_buffer addObject:block];
}

#pragma mark - BufferedPromise

- (instancetype)bufferDone:(DoneCallback)done
{
    if (_flushed)
        [_promise done:done];
    else if (_done == nil)
        _done = [NSMutableArray arrayWithObject:done];
    else
        [_done addObject:done];
    return self;
}

- (instancetype)bufferFail:(FailCallback)fail
{
    if (_flushed)
        [_promise fail:fail];
    else if (_fail == nil)
        _fail = [NSMutableArray arrayWithObject:fail];
    else
        [_fail addObject:fail];
    return self;
}

- (instancetype)bufferError:(ErrorCallback)error
{
    if (_flushed)
        [_promise error:error];
    else
        [self fail:^(id reason, BOOL *handled) {
            if ([reason isKindOfClass:NSError.class])
                error(reason, handled);
        }];
    return self;
}

- (instancetype)bufferException:(ExceptionCallback)exception
{
    if (_flushed)
        [_promise exception:exception];
    else
        [self fail:^(id reason, BOOL *handled) {
            if ([reason isKindOfClass:NSException.class])
                exception(reason, handled);
        }];
    return self;
}

- (instancetype)bufferCancel:(CancelCallback)cancel
{
    if (_flushed)
        [_promise cancel:cancel];
    else if (_cancel == nil)
        _cancel = [NSMutableArray arrayWithObject:cancel];
    else
        [_cancel addObject:cancel];
    return self;
}

- (instancetype)bufferProgress:(ProgressCallback)progress
{
    if (_flushed)
        [_promise progress:progress];
    else if (_progress == nil)
        _progress = [NSMutableArray arrayWithObject:progress];
    else
        [_progress addObject:progress];
    return self;
}

- (instancetype)bufferAlways:(AlwaysCallback)always
{
    if (_flushed)
        [_promise always:always];
    else if (_always == nil)
        _always = [NSMutableArray arrayWithObject:always];
    else
        [_always addObject:always];
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = [super methodSignatureForSelector:sel];
    return signature ? signature : [(id)_promise methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:_promise];
    [invocation invoke];
    
    if ([invocation returnsObject])
    {
        id result = [invocation objectReturnValue];
        
        if (result == _promise)
            result = self;
        else
            return;
        
        [invocation setObjectReturnValue:result];
    }
}

- (void)dealloc
{
    _buffer  = nil;
    _promise = nil;
    _done = _fail = _cancel = _always = _progress = nil;
}

@end

#pragma clang diagnostic pop
