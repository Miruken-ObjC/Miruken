//
//  MKViewControllerWapperView.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/11/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKViewControllerWapperView.h"

@implementation MKViewControllerWapperView

+ (instancetype)wrapperViewForView:(UIView *)view frame:(CGRect)frame
{
    MKViewControllerWapperView *wrapper = [[self alloc] initWithFrame:frame];
    wrapper.autoresizingMask            = UIViewAutoresizingFlexibleRightMargin
                                        | UIViewAutoresizingFlexibleBottomMargin;
    wrapper.frame                       = wrapper.frame;
    return wrapper;
}

+ (instancetype)existingWrapperViewForView:(UIView *)view
{
    return [view.superview isKindOfClass:MKViewControllerWapperView.class]
         ? (MKViewControllerWapperView *)(view.superview)
         : nil;
}

- (UIView *)wrappedView
{
    NSArray *subViews = self.subviews;
    return  subViews.count > 0 ? subViews[0] : nil;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.wrappedView.frame = self.bounds;
}

@end
