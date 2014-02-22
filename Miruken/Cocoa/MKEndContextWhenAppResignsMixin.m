//
//  MKEndContextWhenAppResignsMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKEndContextWhenAppResignsMixin.h"
#import "MKContextual.h"
#import "MKMixin.h"

@interface MKEndContextWhenAppResignsMixin() <MKContextual, UIApplicationDelegate>
@end

@implementation MKEndContextWhenAppResignsMixin

+ (void)mixInto:(Class)class
{
    if ([class conformsToProtocol:@protocol(MKContextual)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKEndContextWhenAppResignsMixin requires the target "
                                               "class to conform to the Contextual protocol."
                                     userInfo:nil];
    
    [class mixinFrom:self];
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self EndContext_applicationWillResignActive:application];
}

- (void)swizzleEndContext_applicationWillResignActive:(UIApplication *)application
{
    [self EndContext_applicationWillResignActive:application];
    [self swizzleEndContext_applicationWillResignActive:application];
}

- (void)EndContext_applicationWillResignActive:(UIApplication *)application
{
    [self endContext];
}

@end
