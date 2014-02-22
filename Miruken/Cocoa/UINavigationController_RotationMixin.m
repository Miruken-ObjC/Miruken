//
//  UINavigationController_RotationMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/13/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController_RotationMixin.h"
#import "MKMixin.h"

/**
  Note: UINavigationControllers don't support different view controller orientations
        very well so we always use the first view controller to control the rotation
        and orientation characteristics.
 */

@implementation UINavigationController_RotationMixin

- (UIViewController *)_firstViewController
{
    return ((UINavigationController *)self).viewControllers[0];
}

- (BOOL)shouldAutorotate
{
    return self._firstViewController.shouldAutorotate;
}

- (BOOL)swizzleRotation_shouldAutorotate
{
    return self._firstViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self._firstViewController.supportedInterfaceOrientations;
}

- (NSUInteger)swizzleRotation_supportedInterfaceOrientations
{
    return self._firstViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self._firstViewController.preferredInterfaceOrientationForPresentation;
}

- (UIInterfaceOrientation)swizzleRotation_preferredInterfaceOrientationForPresentation
{
    return self._firstViewController.preferredInterfaceOrientationForPresentation;
}

@end
