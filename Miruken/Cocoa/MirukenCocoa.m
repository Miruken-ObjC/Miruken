//
//  MirukenCocoa.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContextual.h"
#import "UIViewController_ContextualMixin.h"
#import "UINavigationController_ContextualMixin.h"
#import "MKMixingIn.h"

@interface MirukenCocoa : NSObject
@end

@implementation MirukenCocoa

+ (void)load
{
    [MKContextualMixin                      mixInto:UIViewController.class];
    [UIViewController_ContextualMixin       mixInto:UIViewController.class];
    [UINavigationController_ContextualMixin mixInto:UINavigationController.class];
}

@end
