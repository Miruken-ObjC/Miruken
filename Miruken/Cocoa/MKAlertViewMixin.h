//
//  MKAlertViewMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 1/27/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  Protocol adopted by targets requiring UIAlertView mixin.
 */

@protocol MKAlertViewDelegate <UIAlertViewDelegate>

@optional
- (UIAlertView *)alertView;

- (void)setAlertView:(UIAlertView *)alertView;

@end

/**
  This class is an opaque mix-in that dismisses the active UIAlertView when the
  application becomes inactive.
  e.g. MKAlertViewMixin mixInto:MyViewController.class]
 */

@interface MKAlertViewMixin : NSObject

@end
