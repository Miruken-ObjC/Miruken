//
//  MKAsyncObject.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncObject.h"
#import "MKAsyncResult.h"

@implementation MKAsyncObject
{
    id                               _target;
    __weak id                        _weakTarget;
    id<MKAsyncDelegate>                _delegate;
    id<MKAsyncResult>                  _asyncResult;
    __autoreleasing id<MKAsyncResult> *_outAsyncResult;
}

- (id)initWithClass:(Class)aClass delegate:(id<MKAsyncDelegate>)delegate
{
    return [self initWithObject:[[aClass alloc] init] delegate:delegate];
}

- (id)initWithObject:(id)anObject delegate:(id<MKAsyncDelegate>)delegate
{
    _target         = anObject;
    _delegate       = delegate;
    _outAsyncResult = nil;
    return self;
}

- (id)outAsyncResult:(id<MKAsyncResult> __autoreleasing *)outAsyncResult
{
    _outAsyncResult = outAsyncResult;
    return self;
}

- (id)weak
{
    _weakTarget = _target;
    _target     = nil;
    return self;
}

- (id<MKAsyncResult>)asyncResult
{
    return _asyncResult;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return _target
        ? [_target methodSignatureForSelector:selector]
        : [_weakTarget methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    id<MKAsyncResult> asyncResult = [_delegate asyncResultForInvocation:invocation];
    
    if (_outAsyncResult)
    {
        *_outAsyncResult = asyncResult;
        _outAsyncResult  = nil;
    }
    
    if ([asyncResult isProxyResult])
    {
        _asyncResult = asyncResult;
        SEL selector = [invocation selector];
        [invocation setSelector:@selector(asyncResult)];
        [invocation invokeWithTarget:self];
        [invocation setSelector:selector];
        _asyncResult = nil;
    }
    
    [invocation setTarget:_target ? _target : _weakTarget];
    
    if (invocation.argumentsRetained == NO)
        [invocation retainArguments];

    [_delegate completeResult:asyncResult];
}

- (void)dealloc
{
    _delegate       = nil;
    _asyncResult    = nil;
    _outAsyncResult = nil;
}

@end
