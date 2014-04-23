//
//  MKThreadDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/27/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKThreadDelegate.h"

@implementation MKThreadDelegate
{
    NSThread  *_thread;
}

+ (instancetype)onThread:(NSThread *)thread
{
    MKThreadDelegate *threadDelegate = [self new];
    threadDelegate->_thread          = thread;
    return threadDelegate;
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    if ([NSThread currentThread] == _thread)
        [super completeResult:asyncResult];
    else
    {
        [self performSelector:@selector(completeResultOnThread:) onThread:_thread
                   withObject:asyncResult waitUntilDone:NO];
    }
}

- (void)completeResultOnThread:(id<MKAsyncResult>)asyncResult
{
    [super completeResult:asyncResult];
}

@end
