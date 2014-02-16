//
//  MKGrandCentralDispatchDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/16/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKGrandCentralDispatchDelegate.h"

@implementation MKGrandCentralDispatchDelegate
{
    dispatch_queue_t _queue;
    NSTimeInterval   _delay;
}

+ (instancetype)dispatchMainQueue
{
    return [self dispatchQueue:dispatch_get_main_queue()];
}

+ (instancetype)dispatchGlobalQueue
{
    return [self dispatchGlobalQueueWithPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
}

+ (instancetype)dispatchGlobalQueueWithPriority:(long)priority
{
    return [self dispatchQueue:dispatch_get_global_queue(priority, 0)];
}

+ (instancetype)dispatchGlobalQueueWithDelay:(NSTimeInterval)delay
{
    MKGrandCentralDispatchDelegate *gcd = [self dispatchGlobalQueue];
    gcd->_delay                       = delay;
    return gcd;
}

+ (instancetype)dispatchQueue:(dispatch_queue_t)queue
{
    MKGrandCentralDispatchDelegate *gcdDelegate = [MKGrandCentralDispatchDelegate new];
    gcdDelegate->_queue = queue;
    return gcdDelegate;
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    if (_delay)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _delay * NSEC_PER_SEC);
        dispatch_after(popTime, _queue, ^{ [super completeResult:asyncResult]; });
    }
    else
        dispatch_async(_queue, ^{ [super completeResult:asyncResult]; });
}

@end
