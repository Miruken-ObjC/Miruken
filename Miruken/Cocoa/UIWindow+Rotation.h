//
//  UIWindow+Rotation.h
//  Craig Neuwirt
//
//  Created by Craig Neuwirt on 9/17/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (UIWindow_Rotation)

@property (assign, nonatomic, getter=isAutoRotationSuppressed) BOOL suppressAutoRotation;

- (void)refreshOrientation;

@end
