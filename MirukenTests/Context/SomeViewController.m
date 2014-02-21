//
//  SomeViewController.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "SomeViewController.h"
#import "Configuration.h"
#import "MKMixin.h"

@implementation SomeViewController

- (void)doSomething
{    
}

- (NSInteger)add:(NSInteger)op to:(NSInteger)operand;
{
    return op + operand;
}

- (Configuration *)provideConfiguration
{
    Configuration *config = [Configuration new];
    config.url            = @"www.improving.com";
    return config;
}

- (MKDeferred *)longRunningOperation
{
    return [MKDeferred new];
}

- (void)dealloc
{
    NSLog(@"-SomeViewController dealloc");
}

@end