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

- (BOOL)isAtTop
{
    return (self.contentInset.top + self.contentOffset.y) == 0;
}

- (BOOL)isBeforeTop
{
    return (self.contentInset.top + self.contentOffset.y) < 0;
}

- (BOOL)isAtBottom
{
    return (self.contentOffset.y - self.contentInset.bottom) ==
    (self.contentSize.height - self.bounds.size.height);
}

- (BOOL)isAfterBottom
{
    return (self.contentOffset.y - self.contentInset.bottom) >
    (self.contentSize.height - self.bounds.size.height);
}

- (void)stopScrolling
{
    [self setContentOffset:self.contentOffset animated:NO];
}

@end
