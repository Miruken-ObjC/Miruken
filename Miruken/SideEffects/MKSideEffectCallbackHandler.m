//
//  SideEffectCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKSideEffectCallbackHandler.h"
#import <libkern/OSAtomic.h>

static volatile int32_t pendingNetworkActivity;

@implementation MKSideEffectCallbackHandler

- (void)beginNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    OSAtomicIncrement32(&pendingNetworkActivity);
}

- (void)endNetworkActivity
{
    if (OSAtomicDecrement32(&pendingNetworkActivity) == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
}

@end
