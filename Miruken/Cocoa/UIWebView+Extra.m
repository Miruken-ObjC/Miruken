//
//  UIWebView+Extra.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/7/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "UIWebView+Extra.h"
#import "MKInhibitInputAccessoryView.h"
#import "MKMixin.h"

@implementation UIWebView (UIWebView_Extra)

+ (void)inhibitInputAccessoryView
{
    UIWebView *prototype = [[UIWebView alloc] initWithFrame:CGRectZero];
    for (UIView *subview in prototype.scrollView.subviews)
    {
        if ([subview isKindOfClass:UIImageView.class])
            continue;
        
        [MKMixin from:MKInhibitInputAccessoryView.class into:subview.class
            followInheritance:NO force:YES];
    }
}

@end
