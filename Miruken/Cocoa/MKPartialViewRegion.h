//
//  MKPartialViewRegion.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKViewRegion.h"
#import "MKContext.h"

@interface MKPartialViewRegion : UIView <MKViewRegion>

- (MKContext *)context;

- (UIViewController *)controller;

@end
