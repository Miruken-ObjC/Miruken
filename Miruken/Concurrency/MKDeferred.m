//
//  MKDeferred.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDeferred.h"
#import "MKBufferedPromise.h"
#import <libkern/OSAtomic.h>
#import <pthread.h>

#pragma mark - Promise

@interface MKPromise : NSObject <MKPromise>

@property (readonly, strong) MKDeferred *deferred;

+ (instancetype)deferredPromise:(MKDeferred *)deferred;

@end

@implementation MKPromise

+ (id)deferredPromise:(MKDeferred *)deferred
{
    return [[MKPromise alloc] initWithDeferred:deferred];
}

- (id)initWithDeferred:(MKDeferred *)deferred
{
    if (self = [super init])
        _deferred = deferred;
    return self;
}

- (DeferredState)state
{
    return [_deferred state];
}

- (BOOL)isPending
{
    return [_deferred isPending];
}

- (BOOL)isResolved
{
    return [_deferred isResolved];
}

- (BOOL)isRejected
{
    return [_deferred isRejected];
}

- (BOOL)isCancelled
{
    return [_deferred isCancelled];
}

- (instancetype)done:(DoneCallback)done
{
    [_deferred done:done];
    return self;
}

- (instancetype)fail:(FailCallback)fail
{
    [_deferred fail:fail];
    return self;
}

- (instancetype)error:(ErrorCallback)error
{
    [_deferred error:error];
    return self;
}

- (instancetype)exception:(ExceptionCallback)exception
{
    [_deferred exception:exception];
    return self;
}

- (instancetype)cancel:(CancelCallback)cancel
{
    [_deferred cancel:cancel];
    return self;
}

- (instancetype)always:(AlwaysCallback)always
{
    [_deferred always:always];
    return self;
}

- (instancetype)progress:(ProgressCallback)progress
{
    [_deferred progress:progress];
    return self;
}

- (instancetype)then:(NSArray *)done fail:(NSArray *)fail
{
    [_deferred then:done fail:fail];
    return self;
}

- (instancetype)then:(NSArray *)done fail:(NSArray *)fail progress:(NSArray *)progress
{
    [_deferred then:done fail:fail progress:progress];
    return self;
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter
{
    return [_deferred pipe:doneFilter];
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
{
    return [_deferred pipe:doneFilter failFilter:failFilter];
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
     progressFilter:(ProgressFilter)progressFilter
{
    return [_deferred pipe:doneFilter failFilter:failFilter progressFilter:progressFilter];
}

- (id<MKBufferedPromise>)buffer
{
    return [MKBufferedPromise bufferPromise:self];
}

- (BOOL)waitTimeInterval:(NSTimeInterval)timeInterval
{
    return [_deferred waitTimeInterval:timeInterval];
}

- (BOOL)waitUntilDate:(NSDate *)date
{
    return [_deferred waitUntilDate:date];
}

- (void)wait
{
    [_deferred wait];
}

- (void)cancel
{
    [_deferred cancel];
}

@end

#pragma mark - Pipe

@interface MKPipe : NSObject <MKPromise>

+ (instancetype)filteredPromise:(id<MKPromise>)promise doneFilter:(DoneFilter)doneFilter
                     failFilter:(FailFilter)failFilter progressFilter:(ProgressFilter)progressFilter;

@end

#pragma mark - Deferred

@implementation MKDeferred
{
    NSMutableArray      *_done;
    NSMutableArray      *_fail;
    NSMutableArray      *_cancel;
    NSMutableArray      *_always;
    NSMutableArray      *_progress;
    NSMutableArray      *_notifications;
    pthread_mutexattr_t  _mutexAttr;
    pthread_mutex_t      _mutex;
    pthread_cond_t       _conditionVariable;
    BOOL                 _failureHandled;
    id                   _result;
}

@synthesize state = _state;

- (id)init
{
    if (self = [super init])
    {
        _state = DeferredStatePending;
        pthread_mutexattr_init(&_mutexAttr);
        pthread_mutexattr_settype(&_mutexAttr, PTHREAD_MUTEX_RECURSIVE);
        pthread_cond_init(&_conditionVariable, NULL);
        pthread_mutex_init(&_mutex, &_mutexAttr);
    }
    return self;
}

+ (instancetype)resolved
{
    return [[MKDeferred new] resolve];
}

+ (instancetype)resolved:(id)result
{
    return [[MKDeferred new] resolve:result];
}

+ (instancetype)rejected:(id)reason
{
    return [[MKDeferred new] reject:reason];
}

- (BOOL)isPending
{
    return _state == DeferredStatePending;
}

- (BOOL)isResolved
{
    return _state == DeferredStateResolved;
}

- (BOOL)isRejected
{
    return _state == DeferredStateRejected;
}

- (BOOL)isCancelled
{
    return _state == DeferredStateCancelled;
}

- (id<MKPromise>)promise
{
    return [MKPromise deferredPromise:self];
}

- (instancetype)done:(DoneCallback)done
{
    if (done == nil)
        return self;
    
    if (_state == DeferredStateResolved)
    {
        done(_result);
        return self;
    }
    
    pthread_mutex_lock(&_mutex);

    @try
    {
        if (_state == DeferredStatePending)
        {
            if (_done == nil)
                _done = [NSMutableArray arrayWithObject:done];
            else
                [_done addObject:done];
        }
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (instancetype)fail:(FailCallback)fail
{
    if (fail == nil)
        return self;
    
    if (_state == DeferredStateRejected)
    {
        fail(_result, &_failureHandled);
        return self;
    }
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (_state == DeferredStatePending)
        {
            if (_fail == nil)
                _fail = [NSMutableArray arrayWithObject:fail];
            else
                [_fail addObject:fail];
        }
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (instancetype)error:(ErrorCallback)error
{
    return [self fail:^(id reason, BOOL *handled) {
        if ([reason isKindOfClass:NSError.class])
            error(reason, handled);
    }];
}

- (instancetype)exception:(ExceptionCallback)exception
{
    return [self fail:^(id reason, BOOL *handled) {
        if ([reason isKindOfClass:NSException.class])
            exception(reason, handled);
    }];
}

- (instancetype)cancel:(CancelCallback)cancel
{
    if (cancel == nil)
        return self;
    
    if (_state == DeferredStateCancelled)
    {
        cancel();
        return self;
    }
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (_state == DeferredStatePending)
        {
            if (_cancel == nil)
                _cancel = [NSMutableArray arrayWithObject:cancel];
            else
                [_cancel addObject:cancel];
        }
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (instancetype)always:(AlwaysCallback)always
{
    if (always == nil)
        return self;
    
    if (_state != DeferredStatePending)
    {
        always();
        return self;
    }
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (_always == nil)
            _always = [NSMutableArray arrayWithObject:always];
        else
            [_always addObject:always];
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (id<MKPromise>)progress:(ProgressCallback)progress
{
    if (progress == nil)
        return self;
    
    pthread_mutex_lock(&_mutex);

    @try
    {
        if (_state == DeferredStatePending)
        {
            if (_progress == nil)
                _progress = [NSMutableArray arrayWithObject:progress];
            else
                [_progress addObject:progress];
        }
        
        if (_notifications)
            for (id notification in _notifications)
                progress(notification, YES);
        
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (id<MKPromise>)then:(NSArray *)done fail:(NSArray *)fail
{
    return [self then:done fail:fail progress:nil];
}

- (id<MKPromise>)then:(NSArray *)done fail:(NSArray *)fail progress:(NSArray *)progress
{
    if (_state == DeferredStateResolved)
    {
        if (done)
        {
            for (DoneCallback doneCB in done)
                doneCB(_result);
        }
        return self;
    }

    if (_state == DeferredStateRejected)
    {
        if (fail)
        {
            for (FailCallback failCB in fail)
                failCB(_result, &_failureHandled);
        }
        return self;
    }
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (done)
        {
            if (_done == nil)
                _done = [NSMutableArray arrayWithArray:done];
            else
                [_done addObjectsFromArray:done];
        }
        
        if (fail)
        {
            if (_fail == nil)
                _fail = [NSMutableArray arrayWithArray:fail];
            else
                [_fail addObjectsFromArray:fail];
        }
        
        if (progress)
        {
            if (_progress == nil)
                _progress = [NSMutableArray arrayWithArray:progress];
            else
                [_progress addObjectsFromArray:progress];
        }
        
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (id<MKBufferedPromise>)buffer
{
    return [MKBufferedPromise bufferPromise:self];
}

- (instancetype)resolve
{
    return [self resolve:nil];
}

- (instancetype)resolve:(id)result
{
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        // Ignore result if cancelled
        
        if (_state == DeferredStateCancelled)
            return self;
        
        if (_state != DeferredStatePending)
            @throw [NSException
                    exceptionWithName: NSInternalInconsistencyException
                    reason: @"Deferred can only be resolved in the pending state"
                    userInfo: nil];
        
        _state  = DeferredStateResolved;
        _result = result;
        
        if (_done)
            for (DoneCallback done in _done)
                done(_result);
        
        if (_always)
            for (AlwaysCallback always in _always)
                always();
        
        _done = _fail = _cancel = _always = _progress = nil;
        return self;
    }
    @finally
    {
        pthread_cond_broadcast(&_conditionVariable);
        pthread_mutex_unlock(&_mutex);
    }
}

- (instancetype)reject:(id)reason
{
    return [self reject:reason handled:NULL];
}

- (instancetype)reject:(id)reason handled:(BOOL *)handled
{    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        // Ignore failure if cancelled
        
        if (_state == DeferredStateCancelled)
            return self;
        
        if (_state != DeferredStatePending)
            @throw [NSException
                    exceptionWithName: NSInternalInconsistencyException
                    reason: @"Deferred can only be rejected in the pending state"
                    userInfo: nil];
        
        _state  = DeferredStateRejected;
        _result = reason;
        
        if (_fail)
        {
            if (handled == NULL)
                handled = &_failureHandled;
            for (FailCallback fail in _fail)
                fail(_result, handled);
        }
        
        if (_always)
            for (AlwaysCallback always in _always)
                always();
        
        _done = _fail = _cancel = _always = _progress = nil;
        
        return self;
    }
    @finally
    {
        pthread_cond_broadcast(&_conditionVariable);
        pthread_mutex_unlock(&_mutex);
    }
}

- (void)cancel
{
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (_state != DeferredStatePending)
            return;
        
        _state = DeferredStateCancelled;
        
        if (_cancel)
            for (CancelCallback cancel in _cancel)
                cancel();
        
        if (_always)
            for (AlwaysCallback always in _always)
                always();
        
        _done = _fail = _cancel = _always = _progress = nil;
    }
    @finally
    {
        pthread_cond_broadcast(&_conditionVariable);
        pthread_mutex_unlock(&_mutex);
    }    
}

- (instancetype)notify:(id)progress
{
    return [self notify:progress queue:NO];
}

- (instancetype)notify:(id)progress queue:(BOOL)queue
{
    if (_state != DeferredStatePending)
        return self;
    
    pthread_mutex_lock(&_mutex);
    
    if (queue)
    {
        if (_notifications == nil)
            _notifications = [NSMutableArray new];
        [_notifications addObject:progress];
    }

    @try
    {
        if (_progress)
            for (ProgressCallback notify in _progress)
                notify(progress, NO);
        return self;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }    
}

- (instancetype)track:(id<MKPromise>)promise
{
    [[[[promise
     done:^(id result) {
         [self resolve:result];
     }]
     progress:^(id progress, BOOL queued) {
         [self notify:progress queue:queued];
     }]
     fail:^(id reason, BOOL *handled) {
         [self reject:reason handled:handled];
     }]
     cancel:^{
         [self cancel];
     }];
    return self;
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter
{
    return [MKPipe filteredPromise:self doneFilter:doneFilter failFilter:nil progressFilter:nil];
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
{
    return [MKPipe filteredPromise:self doneFilter:doneFilter failFilter:failFilter progressFilter:nil];
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
     progressFilter:(ProgressFilter)progressFilter
{
    return [MKPipe filteredPromise:self doneFilter:doneFilter failFilter:failFilter
                  progressFilter:progressFilter];
}

- (BOOL)waitTimeInterval:(NSTimeInterval)timeInterval
{
    return [self waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
}

- (BOOL)waitUntilDate:(NSDate *)date
{
    if (_state != DeferredStatePending)
        return YES;
    
    double second, subsecond;
    NSTimeInterval interval = [date timeIntervalSince1970];
    subsecond               = modf(interval, &second);
    struct timespec time    = { second, subsecond * NSEC_PER_SEC };
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        while (_state == DeferredStatePending)
        {
            if (pthread_cond_timedwait(&_conditionVariable, &_mutex, &time) == ETIMEDOUT)
                return NO;
        }
        return YES;
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

- (void)wait
{
    if (_state != DeferredStatePending)
        return;
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        while (_state == DeferredStatePending)
            pthread_cond_wait(&_conditionVariable, &_mutex);        
    }
    @finally
    {
        pthread_mutex_unlock(&_mutex);
    }
}

+ (id<MKPromise>)when:(id)condition, ...
{
    va_list args;
    va_start(args, condition);
    NSMutableArray *conditions = [NSMutableArray new];
    for (id arg = condition; arg != nil; arg = va_arg(args, id))
        [conditions addObject:arg];
    va_end(args);
    
    return [self whenAll:conditions];
}

+ (id<MKPromise>)whenAll:(NSArray *)conditions
{
    switch (conditions.count)
    {
        case 0:
            return [[MKDeferred resolved] promise];
            
        case 1:
        {
            id condition = conditions[0];
            return [condition conformsToProtocol:@protocol(MKPromise)]
                ? condition
                : [[MKDeferred resolved:condition] promise];
        }
    }

    MKDeferred                *master  = [MKDeferred new];
    __block NSMutableArray  *results = [NSMutableArray arrayWithArray:conditions];
    __block volatile int32_t pending = 1;
    
    for (NSUInteger index = 0; index < results.count; ++index)
    {
        id condition = results[index];
        if ([condition conformsToProtocol:@protocol(MKPromise)])
        {
            OSAtomicIncrement32(&pending);
            
            [[[((id<MKPromise>)condition)
                done:^(id result) {
                    if (results)
                    {
                        if (result == nil)
                            result = [NSNull null];
                        [results replaceObjectAtIndex:index withObject:result];
                    }
                    if (OSAtomicDecrement32(&pending) == 0)
                        [master resolve:results];
                }]
                fail:^(id reason, BOOL *handled) {
                    @synchronized(master)
                    {
                        if (master.isPending)
                        {
                            [master reject:reason handled:handled];
                            results = nil;
                        }
                    }
                }]
              cancel:^{
                  @synchronized(master)
                  {
                      if (master.isPending)
                      {
                          [master cancel];
                          results = nil;
                      }
                  }               
              }];
        }
    }
    
    if (OSAtomicDecrement32(&pending) == 0)
        [master resolve:results];
    
    return [master promise];
}

- (void)dealloc
{
    _result    = nil;
    _done = _fail = _cancel = _always = _progress = nil;
    
    pthread_mutexattr_destroy(&_mutexAttr);
    pthread_cond_destroy(&_conditionVariable);
    pthread_mutex_destroy(&_mutex);
}

@end

#pragma mark - Pipe Implementation

@implementation MKPipe
{
    MKDeferred      *_pipe;
    DoneFilter       _doneFilter;
    FailFilter       _failFilter;
    ProgressFilter   _progressFilter;
}

+ (instancetype)filteredPromise:(id<MKPromise>)promise doneFilter:(DoneFilter)doneFilter
                     failFilter:(FailFilter)failFilter progressFilter:(ProgressFilter)progressFilter
{
    return [[MKPipe alloc] initWithPromise:promise doneFilter:doneFilter failFilter:failFilter
                          progressFilter:progressFilter];
}

- (id)initWithPromise:(id<MKPromise>)promise doneFilter:(DoneFilter)doneFilter
           failFilter:(FailFilter)failFilter progressFilter:(ProgressFilter)progressFilter
{
    if (self = [super init])
    {
        _pipe           = [MKDeferred new];
        _doneFilter     = doneFilter;
        _failFilter     = failFilter;
        _progressFilter = progressFilter;
        
        [[[[promise
            done:^(id result) {
                if (_doneFilter)
                {
                    result = _doneFilter(result);
                    if ([result conformsToProtocol:@protocol(MKPromise)])
                    {
                        [[[[((id<MKPromise>)result)
                            done:^(id pipedResult) {
                                [_pipe resolve:pipedResult];
                            }]
                           fail:^(id reason, BOOL *handled) {
                               [_pipe reject:reason handled:handled];
                           }]
                          cancel:^{ [_pipe cancel]; }]
                         progress:^(id progress, BOOL queued) {
                             [_pipe notify:progress queue:queued];
                         }];
                        [_pipe cancel:^{ [result cancel]; }];
                        return;
                    }
                }
                [_pipe resolve:result];
            }]
           fail:^(id reason, BOOL *handled) {
               if (_failFilter)
                   reason = _failFilter(reason);
               [_pipe reject:reason handled:handled];
           }]
          cancel:^{ [_pipe cancel]; }]
         progress:^(id progress, BOOL queued) {
             if (_progressFilter)
                 progress = _progressFilter(progress, queued);
             [_pipe notify:progress];
         }];
        
        [_pipe cancel:^{ [promise cancel]; }];
    }
    return self;
}

- (DeferredState)state
{
    return [_pipe state];
}

- (BOOL)isPending
{
    return [_pipe isPending];
}

- (BOOL)isResolved
{
    return [_pipe isResolved];
}

- (BOOL)isRejected
{
    return [_pipe isRejected];
}

- (BOOL)isCancelled
{
    return [_pipe isCancelled];
}

- (id<MKPromise>)done:(DoneCallback)done
{
    [_pipe done:done];
    return self;
}

- (id<MKPromise>)fail:(FailCallback)fail
{
    [_pipe fail:fail];
    return self;
}

- (id<MKPromise>)error:(ErrorCallback)error
{
    [_pipe error:error];
    return self;
}

- (id<MKPromise>)exception:(ExceptionCallback)exception
{
    [_pipe exception:exception];
    return self;
}

- (id<MKPromise>)cancel:(CancelCallback)cancel
{
    [_pipe cancel:cancel];
    return self;
}

- (id<MKPromise>)always:(AlwaysCallback)always
{
    [_pipe always:always];
    return self;
}

- (id<MKPromise>)progress:(ProgressCallback)progress
{
    [_pipe progress:progress];
    return self;
}

- (id<MKPromise>)then:(NSArray *)done fail:(NSArray *)fail
{
    [_pipe then:done fail:fail];
    return self;
}

- (id<MKPromise>)then:(NSArray *)done fail:(NSArray *)fail progress:(NSArray *)progress
{
    [_pipe then:done fail:fail progress:progress];
    return self;
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter
{
    return [[MKPipe alloc] initWithPromise:self doneFilter:doneFilter failFilter:nil
                          progressFilter:nil];
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
{
    return [[MKPipe alloc] initWithPromise:self doneFilter:doneFilter failFilter:failFilter
                          progressFilter:nil];
}

- (id<MKPromise>)pipe:(DoneFilter)doneFilter failFilter:(FailFilter)failFilter
     progressFilter:(ProgressFilter)progressFilter
{
    return [[MKPipe alloc] initWithPromise:self doneFilter:doneFilter failFilter:failFilter
                          progressFilter:progressFilter];
}

- (id<MKBufferedPromise>)buffer
{
    return [MKBufferedPromise bufferPromise:self];
}

- (BOOL)waitTimeInterval:(NSTimeInterval)timeInterval
{
    return [_pipe waitTimeInterval:timeInterval];
}

- (BOOL)waitUntilDate:(NSDate *)date
{
    return [_pipe waitUntilDate:date];
}

- (void)wait
{
    return [_pipe wait];
}

- (void)cancel
{
    [_pipe cancel];
}

@end
