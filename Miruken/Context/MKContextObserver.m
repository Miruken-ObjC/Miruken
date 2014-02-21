//
//  MKContextObserver.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContextObserver.h"

@implementation MKContextObserver
{
    MKContextAction _willEnd;
    MKContextAction _didEnd;
    BOOL            _child;
}

+ (instancetype)contextDidEnd:(MKContextAction)didEnd
{
    MKContextObserver *observer = [self new];
    observer->_didEnd           = didEnd;
    return observer;
}

+ (instancetype)contextWillEnd:(MKContextAction)willEnd didEnd:(MKContextAction)didEnd
{
    MKContextObserver *observer = [self new];
    observer->_willEnd          = willEnd;
    observer->_didEnd           = didEnd;
    return observer;    
}

+ (instancetype)childContextDidEnd:(MKContextAction)didEnd
{
    MKContextObserver *observer = [self contextDidEnd:didEnd];
    observer->_child            = YES;
    return observer;
}

+ (instancetype)childContextWillEnd:(MKContextAction)willEnd didEnd:(MKContextAction)didEnd
{
    MKContextObserver *observer = [self contextWillEnd:willEnd didEnd:didEnd];
    observer->_child            = YES;
    return observer;
}

#pragma mark - ContextObserver

- (void)contextWillEnd:(id<MKContext>)context
{
    if (_child == NO && _willEnd)
        _willEnd(context);
}

- (void)contextDidEnd:(id<MKContext>)context
{
    if (_child == NO && _didEnd)
        _didEnd(context);
}

- (void)childContextWillEnd:(id<MKContext>)childContext
{
    if (_child && _willEnd)
        _willEnd(childContext);
}

- (void)childContextDidEnd:(id<MKContext>)childContext
{
    if (_child && _didEnd)
        _didEnd(childContext);
}

- (void)dealloc
{
    _willEnd = nil;
    _didEnd  = nil;
}

@end
