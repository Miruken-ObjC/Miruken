//
//  MKMainThreadDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/24/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKMainThreadDelegate.h"

@implementation MKMainThreadDelegate
{
    BOOL _waitUntilDone;
}

+ (instancetype)sharedInstance
{
    static MKMainThreadDelegate *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

+ (instancetype)sharedInstanceWait
{
    static MKMainThreadDelegate *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
        sharedInstance->_waitUntilDone = YES;
    });
    return sharedInstance;
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    if ([NSThread isMainThread])
        [super completeResult:asyncResult];
    else
    {
        [self performSelectorOnMainThread:@selector(completeResultOnMainThread:)
                               withObject:asyncResult waitUntilDone:_waitUntilDone];
    }
}

- (void)completeResultOnMainThread:(id<MKAsyncResult>)asyncResult
{
    [super completeResult:asyncResult];
}

@end
