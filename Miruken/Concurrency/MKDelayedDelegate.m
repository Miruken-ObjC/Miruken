//
//  MKDelayedDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/25/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDelayedDelegate.h"
#import "MKSynchronousResult.h"

@implementation MKDelayedDelegate
{
    NSTimeInterval  _delay;
    BOOL            _onMain;
}

+ (instancetype)withDelay:(NSTimeInterval)delay
{
    MKDelayedDelegate *delayDelegate = [self new];
    delayDelegate->_delay          = delay;
    return delayDelegate;
}

+ (instancetype)withDelayOnMain:(NSTimeInterval)delay
{
    MKDelayedDelegate *delayDelegate = [self withDelay:delay];
    delayDelegate->_onMain         = YES;
    return delayDelegate;
}

- (id<MKAsyncResult>)asyncResultForInvocation:(NSInvocation *)invocation
{
    return [[MKSynchronousResult alloc] initWithInvocation:invocation copyBlockArguments:YES];
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    if (_onMain)
    {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, _delay * NSEC_PER_SEC);
        dispatch_after(when, dispatch_get_main_queue(), ^{ [super completeResult:asyncResult]; });
    }
    else
    {
        [self performSelector:@selector(completeResultAfterDelay:)
                   withObject:asyncResult afterDelay:_delay];
    }
}

- (void)completeResultAfterDelay:(id<MKAsyncResult>)asyncResult
{
    [super completeResult:asyncResult];
}

@end
