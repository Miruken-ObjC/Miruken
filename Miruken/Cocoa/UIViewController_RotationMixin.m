//
//  UIViewController_RotationMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/27/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "UIViewController_RotationMixin.h"
#import "UIWindow+Rotation.h"

@implementation UIViewController_RotationMixin

- (BOOL)shouldAutorotate
{
    return [self Rotation_shouldAutorotate];
}

- (BOOL)swizzleRotation_shouldAutorotate
{
    return [self Rotation_shouldAutorotate] &&
           [self swizzleRotation_shouldAutorotate];
}

- (BOOL)Rotation_shouldAutorotate
{
    // Although not confirmed in documentation, iOS seems to consult EVERY
    // UIWindow's rootViewController during rotation handling.  This can result
    // in ambiguous orientation preferrences which produce undesirable view
    // rotation experiences.  We extended UIWindow to request suppression of
    // auto-rotation processing.
    
    UIViewController *viewController = (UIViewController *)self;
    
    // A view not displayed yet may not have an associated window
    
    while (viewController && viewController.view.window == nil)
        viewController = viewController.parentViewController;
    
    if (viewController == nil)
        viewController = [viewController presentedViewController];
    
    return viewController.view.window.isAutoRotationSuppressed == NO;
}

@end
