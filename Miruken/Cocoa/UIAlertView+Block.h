//
//  UIAlertView+Action.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/11/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MKAlertViewBlock)(NSInteger buttonIndex);

@interface UIAlertView (UIAlertView_Block)

- (void)showUsingBlock:(MKAlertViewBlock)block;

@end
