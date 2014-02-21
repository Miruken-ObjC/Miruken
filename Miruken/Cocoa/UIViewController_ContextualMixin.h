//
//  UIViewController_ContextualMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKContextual.h"

/**
  This class is an mix-in that expands the contextual behavior for
  UIViewController's such that presentViewController and dismissViewController
  will create and destroy child contexts, respectively.  It can be enabled by
    [UIViewController mixinFrom:UIViewController_ContextualMixin.class];
 */

@interface UIViewController_ContextualMixin : UIViewController <MKContextual>

@end


/**
  This category enhances the UIViewController with contextual extensions.
 */

@interface UIViewController (UIViewController_Contextual)

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated
                   completion:(void (^)(void))completion presentedContext:(MKContextAction)presentedContext;


- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
                     dismissedContext:(MKContextAction)dismissedContext;

@end