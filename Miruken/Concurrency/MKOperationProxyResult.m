//
//  MKOperationProxyResult.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/29/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKOperationProxyResult.h"

@implementation MKOperationProxyResult
{
    NSBlockOperation  *_operation;
}

- (id)initWithInvocation:(NSInvocation *)invocation
{
    if (self = [super initWithInvocation:invocation])
        _operation = [NSBlockOperation blockOperationWithBlock:^{ [self complete]; }];
    return self;
}

- (NSOperation *)operation
{
    return _operation;
}

- (void)complete
{
    [super complete];
    _operation = nil;
}

@end
