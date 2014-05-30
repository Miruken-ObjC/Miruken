//
//  MKNavigationOptions.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationOptions.h"
#import "MKTransitionOptions.h"

@interface MKNavigationOptions : MKPresentationOptions

@property (strong, nonatomic) MKTransitionOptions *transition;

@end
