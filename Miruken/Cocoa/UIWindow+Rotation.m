//
//  UIWindow+Rotation.m
//  Craig Neuwirt
//
//  Created by Craig Neuwirt on 9/17/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "UIWindow+Rotation.h"
#import <objc/runtime.h>

@interface OrientationViewController : UIViewController

- (id)initWithOrientation:(NSUInteger)orientation;

@end

@implementation OrientationViewController
{
    NSUInteger _orientation;
}

- (id)initWithOrientation:(NSUInteger)orientation
{
    if (self = [super init])
        _orientation = orientation;
    return self;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return _orientation;
}

@end

@implementation UIWindow (UIWindow_Rotation)

- (void)setSuppressAutoRotation:(BOOL)suppress
{
    objc_setAssociatedObject(self, @selector(isAutoRotationSuppressed), @(suppress), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isAutoRotationSuppressed
{
    NSNumber *suppress = (NSNumber *)objc_getAssociatedObject(self, @selector(isAutoRotationSuppressed));
    return [suppress boolValue];
}

- (void)refreshOrientation;
{
    NSUInteger        orientation = [self deviceOrientationMask];
    UIViewController *rootViewController = self.rootViewController;
    if ([rootViewController respondsToSelector:@selector(visibleViewController)])
        rootViewController = [(id)rootViewController visibleViewController];
    else if (rootViewController.presentedViewController)
        rootViewController = rootViewController.presentedViewController;
    if (rootViewController)
    {
        NSUInteger rootOrientation = [rootViewController supportedInterfaceOrientations];
        if ((rootOrientation & orientation) != orientation)
            orientation = rootOrientation;
        OrientationViewController *orientationController = [[OrientationViewController alloc]
                                                            initWithOrientation:orientation];
        [rootViewController presentViewController:orientationController animated:NO completion:^{
            [rootViewController dismissViewControllerAnimated:NO completion:nil];
        }];
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (NSUInteger)deviceOrientationMask
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationMaskPortrait;
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeLeft;
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}

@end
