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

- (MKPromiseState)state
{
    return [_deferred state];
}

- (instancetype)done:(MKDoneCallback)done
{
    [_deferred done:done];
    return self;
}

- (instancetype)fail:(MKFailCallback)fail
{
    [_deferred fail:fail];
    return self;
}

- (instancetype)error:(MKErrorCallback)error
{
    [_deferred error:error];
    return self;
}

- (instancetype)exception:(MKExceptionCallback)exception
{
    [_deferred exception:exception];
    return self;
}

- (instancetype)cancel:(MKCancelCallback)cancel
{
    [_deferred cancel:cancel];
    return self;
}

- (instancetype)always:(MKAlwaysCallback)always
{
    [_deferred always:always];
    return self;
}

- (instancetype)progress:(MKProgressCallback)progress
{
    [_deferred progress:progress];
    return self;
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter
{
    return [_deferred pipe:doneFilter];
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
{
    return [_deferred pipe:doneFilter failFilter:failFilter];
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
     progressFilter:(MKProgressFilter)progressFilter
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

+ (instancetype)filteredPromise:(id<MKPromise>)promise doneFilter:(MKDoneFilter)doneFilter
                     failFilter:(MKFailFilter)failFilter progressFilter:(MKProgressFilter)progressFilter;

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
        _state = MKPromiseStatePending;
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

- (id<MKPromise>)promise
{
    return [MKPromise deferredPromise:self];
}

- (instancetype)done:(MKDoneCallback)done
{
    if (done == nil)
        return self;
    
    if (_state == MKPromiseStateResolved)
    {
        done(_result);
        return self;
    }
    
    pthread_mutex_lock(&_mutex);

    @try
    {
        if (_state == MKPromiseStatePending)
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

- (instancetype)fail:(MKFailCallback)fail
{
    if (fail == nil)
        return self;
    
    if (_state == MKPromiseStateRejected)
    {
        fail(_result, &_failureHandled);
        return self;
    }
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (_state == MKPromiseStatePending)
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

- (instancetype)error:(MKErrorCallback)error
{
    return [self fail:^(id reason, BOOL *handled) {
        if ([reason isKindOfClass:NSError.class])
            error(reason, handled);
    }];
}

- (instancetype)exception:(MKExceptionCallback)exception
{
    return [self fail:^(id reason, BOOL *handled) {
        if ([reason isKindOfClass:NSException.class])
            exception(reason, handled);
    }];
}

- (instancetype)cancel:(MKCancelCallback)cancel
{
    if (cancel == nil)
        return self;
    
    if (_state == MKPromiseStateCancelled)
    {
        cancel();
        return self;
    }
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        if (_state == MKPromiseStatePending)
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

- (instancetype)always:(MKAlwaysCallback)always
{
    if (always == nil)
        return self;
    
    if (_state != MKPromiseStatePending)
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

- (id<MKPromise>)progress:(MKProgressCallback)progress
{
    if (progress == nil)
        return self;
    
    pthread_mutex_lock(&_mutex);

    @try
    {
        if (_state == MKPromiseStatePending)
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
        
        if (_state == MKPromiseStateCancelled)
            return self;
        
        if (_state != MKPromiseStatePending)
            @throw [NSException
                    exceptionWithName: NSInternalInconsistencyException
                    reason: @"Deferred can only be resolved in the pending state"
                    userInfo: nil];
        
        _state  = MKPromiseStateResolved;
        _result = result;
        
        if (_done)
            for (MKDoneCallback done in _done)
                done(_result);
        
        if (_always)
            for (MKAlwaysCallback always in _always)
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
        
        if (_state == MKPromiseStateCancelled)
            return self;
        
        if (_state != MKPromiseStatePending)
            @throw [NSException
                    exceptionWithName: NSInternalInconsistencyException
                    reason: @"Deferred can only be rejected in the pending state"
                    userInfo: nil];
        
        _state  = MKPromiseStateRejected;
        _result = reason;
        
        if (_fail)
        {
            if (handled == NULL)
                handled = &_failureHandled;
            for (MKFailCallback fail in _fail)
                fail(_result, handled);
        }
        
        if (_always)
            for (MKAlwaysCallback always in _always)
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
        if (_state != MKPromiseStatePending)
            return;
        
        _state = MKPromiseStateCancelled;
        
        if (_cancel)
            for (MKCancelCallback cancel in _cancel)
                cancel();
        
        if (_always)
            for (MKAlwaysCallback always in _always)
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
    if (_state != MKPromiseStatePending)
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
            for (MKProgressCallback notify in _progress)
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

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter
{
    return [MKPipe filteredPromise:self doneFilter:doneFilter failFilter:nil progressFilter:nil];
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
{
    return [MKPipe filteredPromise:self doneFilter:doneFilter failFilter:failFilter progressFilter:nil];
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
     progressFilter:(MKProgressFilter)progressFilter
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
    if (_state != MKPromiseStatePending)
        return YES;
    
    double second, subsecond;
    NSTimeInterval interval = [date timeIntervalSince1970];
    subsecond               = modf(interval, &second);
    struct timespec time    = { second, subsecond * NSEC_PER_SEC };
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        while (_state == MKPromiseStatePending)
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
    if (_state != MKPromiseStatePending)
        return;
    
    pthread_mutex_lock(&_mutex);
    
    @try
    {
        while (_state == MKPromiseStatePending)
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
                        if (master.state == MKPromiseStatePending)
                        {
                            [master reject:reason handled:handled];
                            results = nil;
                        }
                    }
                }]
              cancel:^{
                  @synchronized(master)
                  {
                      if (master.state == MKPromiseStatePending)
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
    MKDoneFilter       _doneFilter;
    MKFailFilter       _failFilter;
    MKProgressFilter   _progressFilter;
}

+ (instancetype)filteredPromise:(id<MKPromise>)promise doneFilter:(MKDoneFilter)doneFilter
                     failFilter:(MKFailFilter)failFilter progressFilter:(MKProgressFilter)progressFilter
{
    return [[MKPipe alloc] initWithPromise:promise doneFilter:doneFilter failFilter:failFilter
                          progressFilter:progressFilter];
}

- (id)initWithPromise:(id<MKPromise>)promise doneFilter:(MKDoneFilter)doneFilter
           failFilter:(MKFailFilter)failFilter progressFilter:(MKProgressFilter)progressFilter
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
                    if ([self chainPromise:result])
                        return;
                }
                [_pipe resolve:result];
            }]
           fail:^(id reason, BOOL *handled) {
               if (_failFilter)
               {
                   reason = _failFilter(reason);
                   if ([self chainPromise:reason])
                       return;
               }
               [_pipe reject:reason handled:handled];
           }]
          cancel:^{ [_pipe cancel]; }]
         progress:^(id progress, BOOL queued) {
             if (_progressFilter)
                 progress = _progressFilter(progress, &queued);
             [_pipe notify:progress queue:queued];
         }];
        
        [_pipe cancel:^{ [promise cancel]; }];
    }
    return self;
}

- (BOOL)chainPromise:(id)object
{
    if ([object conformsToProtocol:@protocol(MKPromise)] == NO)
        return NO;
    
    [[[[((id<MKPromise>)object)
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
    [_pipe cancel:^{ [object cancel]; }];
    return YES;
}

- (MKPromiseState)state
{
    return [_pipe state];
}

- (id<MKPromise>)done:(MKDoneCallback)done
{
    [_pipe done:done];
    return self;
}

- (id<MKPromise>)fail:(MKFailCallback)fail
{
    [_pipe fail:fail];
    return self;
}

- (id<MKPromise>)error:(MKErrorCallback)error
{
    [_pipe error:error];
    return self;
}

- (id<MKPromise>)exception:(MKExceptionCallback)exception
{
    [_pipe exception:exception];
    return self;
}

- (id<MKPromise>)cancel:(MKCancelCallback)cancel
{
    [_pipe cancel:cancel];
    return self;
}

- (id<MKPromise>)always:(MKAlwaysCallback)always
{
    [_pipe always:always];
    return self;
}

- (id<MKPromise>)progress:(MKProgressCallback)progress
{
    [_pipe progress:progress];
    return self;
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter
{
    return [[MKPipe alloc] initWithPromise:self doneFilter:doneFilter failFilter:nil
                          progressFilter:nil];
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
{
    return [[MKPipe alloc] initWithPromise:self doneFilter:doneFilter failFilter:failFilter
                          progressFilter:nil];
}

- (id<MKPromise>)pipe:(MKDoneFilter)doneFilter failFilter:(MKFailFilter)failFilter
     progressFilter:(MKProgressFilter)progressFilter
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
