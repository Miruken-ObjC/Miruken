//
//  MKAsyncDelegate_Subclassing.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/24/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate_Subclassing.h"
#import "MKAsyncResult_Subclassing.h"
#import "MKAsyncProxyResult.h"
#import "NSInvocation+Objects.h"

@implementation MKAsyncDelegate

- (id<MKAsyncResult>)asyncResultForInvocation:(NSInvocation *)invocation
{
    return [invocation returnsObject]
        ? (id)[[MKAsyncProxyResult alloc] initWithInvocation:invocation]
        : (id)[[MKAsyncResult alloc]      initWithInvocation:invocation];
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    [asyncResult complete];
}

@end
