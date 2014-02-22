//
//  UIScrollView+Motion.m
//  Miruken
//
//  Created by Craig Neuwirt on 6/6/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "UIScrollView+Motion.h"

@implementation UIScrollView (UIScrollView_Motion)

- (BOOL)inMotion
{
    return self.isDragging || self.isDecelerating;
}

- (BOOL)isBeforeTop
{
    return self.contentOffset.y <= 0;
}

- (BOOL)isAfterBottom
{
    return self.contentOffset.y >= (self.contentSize.height - self.bounds.size.height);
}

- (void)stopScrolling
{
    [self setContentOffset:self.contentOffset animated:NO];
}

@end
