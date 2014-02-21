//
//  UINavigationController_ContextualMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/12/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKContextual.h"

/**
  This class is an mix-in that expands the contextual behavior for
  UINavigationController's such that pushes and pops create and destroy
  child contexts, respectively.  It can be enabled by
    [UINavigationController mixinFrom:UINavigationController_ContextualMixin.class];
 */

@interface UINavigationController_ContextualMixin : UINavigationController <MKContextual>

@end


/**
  This category enhances the UINavigationController with contextual extensions.
 */

@interface UINavigationController (UINavigationController_Contextual)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
                pushedContext:(MKContextAction)pushedContext;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated poppedContext:(MKContextAction)poppedContext;

@end