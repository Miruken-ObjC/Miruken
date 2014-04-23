//
//  MKGrandCentralTimerDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKGrandCentralTimerDelegate.h"

@implementation MKGrandCentralTimerDelegate
{
    NSTimeInterval     _delay;
    NSTimeInterval     _interval;
    NSTimeInterval     _leeway;
    dispatch_queue_t   _queue;
    dispatch_source_t  _timer;
}

+ (instancetype)scheduleAfterDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval
                            leeway:(NSTimeInterval)leeway
{
    return [self scheduleAfterDelay:delay interval:interval leeway:leeway
                              queue:DISPATCH_TARGET_QUEUE_DEFAULT];
}

+ (instancetype)scheduleOnMainAfterDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval
                                  leeway:(NSTimeInterval)leeway
{
    return [self scheduleAfterDelay:delay interval:interval leeway:leeway
                              queue:dispatch_get_main_queue()];
}

+ (instancetype)scheduleAfterDelay:(NSTimeInterval)delay interval:(NSTimeInterval)interval
                            leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue
{
    MKGrandCentralTimerDelegate *timer = [self new];
    timer->_delay                      = delay;
    timer->_interval                   = interval;
    timer->_leeway                     = leeway;
    timer->_queue                      = queue;
    return timer;
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _delay * NSEC_PER_SEC);
    dispatch_source_set_timer(_timer, popTime, _interval * NSEC_PER_SEC, _leeway * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        if (_interval == 0)
            [super completeResult:asyncResult];
        else
            [asyncResult retry];
    });
    [[asyncResult promise] cancel:^{ dispatch_source_cancel(_timer); }];
    dispatch_resume(_timer);
}

@end
