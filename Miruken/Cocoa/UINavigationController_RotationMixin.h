//
//  UINavigationController_RotationMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/13/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  This class is a mix-in that deferrs rotation decisions to the top controller.
  [UINavigationController mixinFrom:UINavigationController_RotationMixin.class];
 */

@interface UINavigationController_RotationMixin : UINavigationController

@end
