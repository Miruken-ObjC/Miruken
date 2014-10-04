//
//  MKViewControllerWapperView.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/11/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKViewControllerWapperView.h"

@implementation MKViewControllerWapperView

- (id)init
{
    if (self = [super init])
        [self setupWrapper];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self setupWrapper];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self setupWrapper];
    return self;
}

- (void)setupWrapper
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth
                          | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor  = [UIColor clearColor];
}

- (UIView *)wrappedView
{
    NSArray *subViews = self.subviews;
    return subViews.count > 0 ? subViews[0] : nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.wrappedView setFrame:self.bounds];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self.wrappedView setBounds:bounds];
}

- (void)wrapView:(UIView *)view
{
    [[self wrappedView] removeFromSuperview];
    if (view)
    {
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleRightMargin;
        [self insertSubview:view atIndex:0];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.frame = self.superview.bounds;
}

@end
