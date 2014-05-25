//
//  MKNewThreadDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/24/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKNewThreadDelegate.h"

@implementation MKNewThreadDelegate

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    [NSThread detachNewThreadSelector:@selector(_completeResultOnThread:)
                             toTarget:self withObject:asyncResult];
}

- (void)_completeResultOnThread:(id<MKAsyncResult>)asyncResult
{
    [super completeResult:asyncResult];
}

@end
