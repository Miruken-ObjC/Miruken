//
//  UIScrollView+Motion.h
//  Miruken
//
//  Created by Craig Neuwirt on 6/6/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (UIScrollView_Motion)

- (BOOL)inMotion;

- (BOOL)isAtTop;

- (BOOL)isBeforeTop;

- (BOOL)isAtBottom;

- (BOOL)isAfterBottom;

- (void)stopScrolling;

@end
