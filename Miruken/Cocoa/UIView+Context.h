//
//  UIView+Context.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKContext.h"

@interface UIView (Context)

- (MKContext *)nearestContext;

@end
