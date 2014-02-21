//
//  MKContext+Subscribe.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/21/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContext.h"

/**
  Category for simplifying the registration of Context lifecycle changes.
 */

@interface MKContext (MKContext_Subscribe)

- (MKContextUnsubscribe)subscribeWillEnd:(MKContextAction)willEnd;

- (MKContextUnsubscribe)subscribeDidEnd:(MKContextAction)didEnd;

- (MKContextUnsubscribe)subscribeChildWillEnd:(MKContextAction)willEnd;

- (MKContextUnsubscribe)subscribeChildDidEnd:(MKContextAction)didEnd;

@end
