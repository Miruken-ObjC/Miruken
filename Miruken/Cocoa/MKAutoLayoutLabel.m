//
//  MKAutoLayoutLabel.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAutoLayoutLabel.h"

@implementation MKAutoLayoutLabel


- (id)init
{
    if (self = [super init])
        [self configure];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self configure];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self configure];
    return self;
}

- (void)configure
{
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Fit the label to it's contents on rotation or text change
    // http://stackoverflow.com/questions/15927086/uilabel-sizetofit-and-constraints
    if (self.preferredMaxLayoutWidth != [self alignmentRectForFrame:self.frame].size.width)
    {
        self.preferredMaxLayoutWidth = [self alignmentRectForFrame:self.frame].size.width;
        [self.superview setNeedsLayout];
    }
}

@end
