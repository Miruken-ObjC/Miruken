//
//  MKDefaultViewRegion.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDynamicCallbackHandler.h"
#import "MKViewRegionSubclassing.h"

@interface MKDefaultViewRegion : MKDynamicCallbackHandler <MKViewRegionSubclassing>

- (id)initWithWindow:(UIWindow *)window;

@end
