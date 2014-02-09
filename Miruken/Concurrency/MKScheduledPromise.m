//
//  CNScheduledPromise.m
//  Miruken b
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKScheduledPromise.h"
#import "MKBufferedPromise.h"
#import "MKAction.h"
#import "NSInvocation+Objects.h"

@interface MKScheduledPromise()
{
@protected
    id<MKPromise>   _promise;
    MKAction       *_scheduler;
}

@end

@interface ScheduledBufferedPromise : MKScheduledPromise
@end

#pragma mark - ScheduledPromise implementation

@implementation MKScheduledPromise

+ (id<MKPromise>)schedulePromise:(id<MKPromise>)promise schedule:(MKAction *)scheduler
{
    if (promise == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"MKPromise cannot be nil"
                                     userInfo:nil];
    
    if (scheduler == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"scheduler cannot be nil"
                                     userInfo:nil];
    
    return [promise conformsToProtocol:@protocol(MKBufferedPromise)]
         ? (id)[[ScheduledBufferedPromise alloc] initWithPromise:promise schedule:scheduler]
         : (id)[[MKScheduledPromise alloc] initWithPromise:promise schedule:scheduler];
}

- (id)initWithPromise:(id<MKPromise>)promise schedule:(MKAction *)scheduler
{
    _promise   = promise;
    _scheduler = scheduler;
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

- (id)done:(DoneCallback)done
{
    [_promise done:^(id result) {
        [_scheduler do:^{ done(result); }];
    }];
    return self;
}

- (id)fail:(FailCallback)fail
{
    [_promise fail:^(id reason, BOOL *handled) {
        [_scheduler do:^{ fail(reason, handled); }];
    }];
    return self;
}

- (id)error:(ErrorCallback)error
{
    [_promise error:^(NSError *err, BOOL *handled) {
        [_scheduler do:^{ error(err, handled); }];
    }];
    return self;
}

- (id)exception:(ExceptionCallback)exception
{
    [_promise exception:^(NSException *ex, BOOL *handled) {
        [_scheduler do:^{ exception(ex, handled); }];
    }];
    return self;
}

- (id)cancel:(CancelCallback)cancel
{
    [_promise cancel:^{ [_scheduler do:cancel]; }];
    return self;
}

- (id)always:(AlwaysCallback)always
{
    [_promise always:^{ [_scheduler do:always]; }];
    return self;
}

- (id)progress:(ProgressCallback)progress
{
    [_promise progress:^(id info, BOOL queued) {
        [_scheduler do:^{ progress(info, queued); }];
    }];
    return self;
}

- (id)then:(NSArray *)done fail:(NSArray *)fail
{
    return [self then:done fail:fail progress:nil];
}

- (id)then:(NSArray *)done fail:(NSArray *)fail progress:(NSArray *)progress
{
    if (done)
    {
        done = [self mapArray:done map:^(id cb) {
            return (id)^(id result) {
                [_scheduler do:^{
                    ((DoneCallback)cb)(result);
                }];
            };
        }];
    }
    
    if (fail)
    {
        fail = [self mapArray:fail map:^(id cb) {
            return (id)^(id reason, BOOL *handled) {
                [_scheduler do:^{ ((FailCallback)cb)(reason, handled); }];
            };
        }];
    }
    
    if (progress)
    {
        progress = [self mapArray:progress map:^(id cb) {
            return (id)^(id info, BOOL queued) {
                [_scheduler do:^{ ((ProgressCallback)cb)(info, queued); }];
            };
        }];        
    }
    
    [_promise then:done fail:fail progress:progress];
    
    return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [(id)_promise methodSignatureForSelector:sel];
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
        else if ([result conformsToProtocol:@protocol(MKPromise)])
            result = [MKScheduledPromise schedulePromise:result schedule:_scheduler];
        else
            return;
        
        [invocation setObjectReturnValue:result];
    }
}

- (NSArray *)mapArray:(NSArray *)array map:(id (^)(id obj))map
{
    NSMutableArray *mappedArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in array)
    {
        id mapped = map(obj);
        if (mapped)
            [mappedArray addObject:mapped];
    }
    return mappedArray;
}

- (void)dealloc
{
    _promise   = nil;
    _scheduler = nil;
}

@end

#pragma mark - ScheduledBufferedPromise implementation

@implementation ScheduledBufferedPromise

- (id)bufferDone:(DoneCallback)done
{
    [(id<MKBufferedPromise>)_promise bufferDone:^(id result) {
        [_scheduler do:^{ done(result); }];
    }];
    return self;
}

- (id)bufferFail:(FailCallback)fail
{
    [(id<MKBufferedPromise>)_promise bufferFail:^(id reason, BOOL *handled) {
        [_scheduler do:^{ fail(reason, handled); }];
    }];
    return self;
}

- (id)bufferError:(ErrorCallback)error
{
    [(id<MKBufferedPromise>)_promise bufferError:^(NSError *err, BOOL *handled) {
        [_scheduler do:^{ error(err, handled); }];
    }];
    return self;
}

- (id)bufferException:(ExceptionCallback)exception
{
    [(id<MKBufferedPromise>)_promise bufferException:^(NSException *ex, BOOL *handled) {
        [_scheduler do:^{ exception(ex, handled); }];
    }];
    return self;
}

- (id)bufferCancel:(CancelCallback)cancel
{
    [(id<MKBufferedPromise>)_promise bufferCancel:^{ [_scheduler do:cancel]; }];
    return self;
}

- (id)bufferAlways:(AlwaysCallback)always
{
    [(id<MKBufferedPromise>)_promise bufferAlways:^{ [_scheduler do:always]; }];
    return self;
}

- (id)bufferProgress:(ProgressCallback)progress
{
    [(id<MKBufferedPromise>)_promise bufferProgress:^(id info, BOOL queued) {
        [_scheduler do:^{ progress(info, queued); }];
    }];
    return self;
}

@end

