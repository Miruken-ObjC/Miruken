//
//  MKOperationQueueDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/29/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKOperationQueueDelegate.h"
#import "MKOperationProxyResult.h"
#import "MKOperationResult.h"
#import "NSInvocation+Objects.h"
#import <objc/runtime.h>

@implementation MKOperationQueueDelegate
{
    NSOperationQueue  *_queue;
}

+ (instancetype)withQueue:(NSOperationQueue *)queue
{
    MKOperationQueueDelegate *queueDelegate = [MKOperationQueueDelegate new];
    queueDelegate->_queue = queue;
    return queueDelegate;
}

+ (instancetype)forObject:(id)object
{
    return [self withQueue:[self getObjectQueue:object]];
}

- (id<MKAsyncResult>)asyncResultForInvocation:(NSInvocation *)invocation
{
    return [invocation returnsObject]
         ? (id)[[MKOperationProxyResult alloc] initWithInvocation:invocation]
         : (id)[[MKOperationResult alloc]      initWithInvocation:invocation];
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
   [_queue addOperation:[(id<MKOperationResult>)asyncResult operation]];
}

+ (NSOperationQueue *)getObjectQueue:(id)object
{
    @synchronized(object)
    {
        NSOperationQueue *queue = objc_getAssociatedObject(object, _cmd);
        if (queue == nil)
        {
            queue = [NSOperationQueue new];
            objc_setAssociatedObject(object, _cmd, queue, OBJC_ASSOCIATION_RETAIN);
        }
        return queue;
    }
}

@end
