//
//  MKContext+Subscribe.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/21/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContext+Subscribe.h"
#import "MKContextObserver.h"

@implementation MKContext (MKContext_Subscribe)

- (MKContextUnsubscribe)subscribeWillEnd:(MKContextAction)willEnd
{
    return [self subscribe:[MKContextObserver contextWillEnd:willEnd didEnd:nil] retain:YES];
}

- (MKContextUnsubscribe)subscribeDidEnd:(MKContextAction)didEnd
{
    return [self subscribe:[MKContextObserver contextDidEnd:didEnd] retain:YES];
}

- (MKContextUnsubscribe)subscribeChildWillEnd:(MKContextAction)willEnd
{
    return [self subscribe:[MKContextObserver childContextWillEnd:willEnd didEnd:nil] retain:YES];
}

- (MKContextUnsubscribe)subscribeChildDidEnd:(MKContextAction)didEnd
{
    return [self subscribe:[MKContextObserver childContextDidEnd:didEnd] retain:YES];
}

@end
