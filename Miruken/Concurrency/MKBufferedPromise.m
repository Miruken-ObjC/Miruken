//
//  MKBufferedPromise.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/8/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKBufferedPromise.h"
#import "NSInvocation+Objects.h"
#import "MKWhen.h"
#import "EXTScope.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation _MKBufferedPromise
{
    NSMutableArray   *_done;
    NSMutableArray   *_fail;
    NSMutableArray   *_cancel;
    NSMutableArray   *_always;
    NSMutableArray   *_progress;
    NSMutableArray   *_buffer;
    MKPromise         _promise;
    BOOL              _flushed;
}

+ (instancetype)bufferPromise:(MKPromise)promise
{
    return [[self alloc] initWithPromise:promise];
}

- (id)initWithPromise:(MKPromise)promise
{
    if (promise == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"promise cannot be nil"
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

- (MKPromiseState)state
{
    return [_promise state];
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
        for (MKDoneCallback done in _done)
            done(result);
}

- (void)flushFail:(id)reason handled:(BOOL *)handled
{
    if (_fail)
        for (MKFailCallback fail in _fail)
            fail(reason, handled);
}

- (void)flushCancel
{
    if (_cancel)
        for (MKCancelCallback cancel in _cancel)
            cancel();
}

- (void)flushProgress:(id)progress queued:(BOOL)queued
{
    if (_progress)
        for (MKProgressCallback notify in _progress)
            notify(progress, queued);
}

- (void)flushAlways
{
    if (_always)
        for (MKAlwaysCallback always in _always)
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

- (instancetype)bufferDone:(MKDoneCallback)done
{
    return [self bufferDone:nil:done];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)bufferDone:(id)when:(MKDoneCallback)done
{
    if (when)
    {
        MKDoneCallback  innerDone = done;
        MKWhenPredicate condition = [MKWhen criteria:when];
        done = ^(id result) {
            if (condition(result))
                innerDone(result);
        };
    }
    
    if (_flushed)
        [_promise done:done];
    else if (_done == nil)
        _done = [NSMutableArray arrayWithObject:done];
    else
        [_done addObject:done];
    
    return self;
}
#pragma clang diagnostic pop

- (instancetype)bufferFail:(MKFailCallback)fail
{
    return [self bufferFail:nil:fail];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)bufferFail:(id)when:(MKFailCallback)fail
{
    if (when)
    {
        MKFailCallback  innerFail = fail;
        MKWhenPredicate condition = [MKWhen criteria:when];
        fail = ^(id reason, BOOL *handled) {
            if (condition(reason))
                innerFail(reason, handled);
        };
    }
    
    if (_flushed)
        [_promise fail:fail];
    else if (_fail == nil)
        _fail = [NSMutableArray arrayWithObject:fail];
    else
        [_fail addObject:fail];
    
    return self;
}
#pragma clang diagnostic pop

- (instancetype)bufferError:(MKErrorCallback)error
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

- (instancetype)bufferException:(MKExceptionCallback)exception
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

- (instancetype)bufferCancel:(MKCancelCallback)cancel
{
    if (_flushed)
        [_promise cancel:cancel];
    else if (_cancel == nil)
        _cancel = [NSMutableArray arrayWithObject:cancel];
    else
        [_cancel addObject:cancel];
    return self;
}


- (instancetype)bufferProgress:(MKProgressCallback)progress
{
    return [self bufferProgress:nil:progress];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"
- (instancetype)bufferProgress:(id)when:(MKProgressCallback)progress
{
    if (when)
    {
        MKProgressCallback innerProgress = progress;
        MKWhenPredicate    condition     = [MKWhen criteria:when];
        progress = ^(id progress, BOOL queued) {
            if (condition(progress))
                innerProgress(progress, queued);
        };
    }
    
    if (_flushed)
        [_promise progress:progress];
    else if (_progress == nil)
        _progress = [NSMutableArray arrayWithObject:progress];
    else
        [_progress addObject:progress];
    
    return self;
}
#pragma clang diagnostic pop

- (instancetype)bufferAlways:(MKAlwaysCallback)always
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
