//
//  MKCADisplayLinkDelegate.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCADisplayLinkDelegate.h"
#import "MKScope.h"
#import <UIKit/UIKit.h>

@implementation MKCADisplayLinkDelegate
{
    NSRunLoop *_runLoop;
    NSString  *_mode;
}

+ (instancetype)displayLinkOnRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
    MKCADisplayLinkDelegate *displayLink = [self new];
    displayLink->_runLoop                = runLoop;
    displayLink->_mode                   = mode;
    return displayLink;
}

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    NSRunLoop     *runLoop     = _runLoop ? _runLoop : [NSRunLoop mainRunLoop];
    NSString      *mode        = _mode    ? _mode    : NSDefaultRunLoopMode;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:asyncResult
                                                             selector:@selector(repeat)];
    @weakify(displayLink);
    [[asyncResult promise] cancel:^{
        @strongify(displayLink);
        [displayLink invalidate];
    }];
    
    [displayLink addToRunLoop:runLoop forMode:mode];
}

@end
