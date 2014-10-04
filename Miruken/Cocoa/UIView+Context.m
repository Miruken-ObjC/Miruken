//
//  UIView+Context.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "UIView+Context.h"
#import "MKContextual.h"

@implementation UIView (Context)

- (MKContext *)nearestContext
{
    // Hierachry first...
    
    id view = self;
    while (view != nil)
    {
        if ([view respondsToSelector:@selector(context)])
        {
            MKContext *context = [view context];
            if (context) return context;
        }
        view = [view superview];
    }
    
    // Then responder chain...
    
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
    {
        if ([nextResponder respondsToSelector:@selector(context)])
        {
            MKContext *context = [nextResponder context];
            if (context) return context;
        }
    }
    
    return nil;
}

@end
