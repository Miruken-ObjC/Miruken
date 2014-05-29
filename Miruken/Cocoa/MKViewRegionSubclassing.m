//
//  MKViewRegionSubclassing.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/29/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKViewRegionSubclassing.h"
#import "NSObject+Context.h"
#import "NSObject+NotHandled.h"

@implementation MKViewRegionSubclassing

- (BOOL)canPresentWithOptions:(id<MKPresentationOptions>)options
{
    return [self _canPresentWithOptions:options];
}

- (BOOL)swizzleViewRegion_canPresentWithOptions:(id<MKPresentationOptions>)options
{
    return [self swizzleViewRegion_canPresentWithOptions:options]
        || [self _canPresentWithOptions:options];
}

- (BOOL)_canPresentWithOptions:(id<MKPresentationOptions>)options
{
    if (options == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"options cannot be nil"
                                     userInfo:nil];
    BOOL canPresent = NO;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"canPresentWith%@:",
                                         NSStringFromClass([options class])]);
    if ([self respondsToSelector:selector])
    {
        NSMethodSignature *signature  = [self methodSignatureForSelector:selector];
        NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setArgument:&options atIndex:2];
        [invocation invokeWithTarget:self];
        if (strcmp([signature methodReturnType], @encode(BOOL)) == 0)
            [invocation getReturnValue:&canPresent];
    }
    return canPresent;
}

- (BOOL)canPresentWithMKPresentationPolicy:(MKPresentationPolicy *)poicy
{
    for (id<MKPresentationOptions> options in poicy.options)
        if ([self canPresentWithOptions:options] == NO)
            return NO;
    return YES;
}

- (id<MKPromise>)presentViewController:(UIViewController *)viewController
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    [self.composer handle:presentationPolicy greedy:YES];

    return [self canPresentWithOptions:presentationPolicy]
         ? [self presentViewController:viewController withPolicy:presentationPolicy]
         : [self notHandled];
}

- (id<MKPromise>)presentViewController:(UIViewController *)viewController
                            withPolicy:(MKPresentationPolicy *)policy
{
    return [self notHandled];
}

@end
