//
//  MKDeferred+Await.m
//  Miruken
//
//  Created by Craig Neuwirt on 7/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDeferred+Await.h"
#import "MKAsyncProxyResult.h"

NSString * const kDeferredAwaitKey = @"Deferred.Await";

@implementation MKDeferred (Await)

+ (MKDeferred *)await
{
    NSDictionary *threadLocal = [[NSThread currentThread] threadDictionary];
    return [threadLocal valueForKey:kDeferredAwaitKey];
}

+ (MKDeferred *)awaitOrDefault:(MKDeferred *)deferred
{
    MKDeferred *await = [self await];
    return await ? await : deferred;
}

@end
