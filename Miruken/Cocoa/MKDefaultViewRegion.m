//
//  MKDefaultViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDefaultViewRegion.h"
#import "MKModalOptions.h"
#import "MKNavigationOptions.h"
#import "MKWindowOptions.h"
#import "MKContextualHelper.h"
#import "MKPresentationPolicy.h"
#import "MKContext+Subscribe.h"
#import "MKCallbackHandler+Resolvers.h"
#import "MKCallbackHandler+Context.h"
#import "NSObject+Context.h"
#import "UIWindow+Rotation.h"
#import "MKDeferred.h"
#import "MKMixin.h"

@implementation MKDefaultViewRegion
{
    UIWindow *_window;
}

+ (void)initialize
{
    if (self == MKDefaultViewRegion.class)
        [self mixinFrom:MKViewRegionSubclassing.class];
}

- (id)initWithWindow:(UIWindow *)window
{
    if (self = [super init])
        _window = window;
    return self;
}

#pragma mark - MKViewRegionSubclassing

- (BOOL)canPresentWithMKModalOptions:(MKModalOptions *)options
{
    return YES;
}

- (BOOL)canPresentWithMKTransitionOptions:(MKTransitionOptions *)options
{
    return YES;
}

- (BOOL)canPresentWithMKNavigationOptions:(MKNavigationOptions *)options
{
    return YES;
}

- (BOOL)canPresentWithMKWindowOptions:(MKWindowOptions *)options
{
    return YES;
}

- (MKPromise)presentViewController:(UIViewController<MKContextual> *)viewController
                        withPolicy:(MKPresentationPolicy *)policy
{
    MKCallbackHandler *composer = self.composer;
    [policy applyPolicyToViewController:viewController];
    
    MKWindowOptions *windowOptions = [policy optionsWithClass:MKWindowOptions.class];
    if (windowOptions)
        return [self _presentViewControllerWindow:viewController windowOptions:windowOptions];
    
    MKModalOptions *modalOptions = [policy optionsWithClass:MKModalOptions.class];
    if (modalOptions == nil)
    {
        UIViewController       *owner = [composer resolve:UIViewController.class];
        UINavigationController *navigationController = owner.navigationController;
        
        if (navigationController)
        {
            [navigationController pushViewController:viewController animated:YES];
            return [[MKDeferred resolved:viewController.context] promise];
        }
    }
    
    return [self _presentViewControllerModally:viewController modalOptions:modalOptions];
}

- (MKPromise)_presentViewControllerModally:(UIViewController<MKContextual> *)viewController
                              modalOptions:(MKModalOptions *)modalOptions
{
    MKCallbackHandler *composer = self.composer;
    [MKContextualHelper bindChildContextFrom:composer toChild:viewController];
    UIViewController  *owner    = [composer resolve:UIViewController.class];
    if (owner == nil)
        owner = _window.rootViewController;
    if (owner)
        [owner presentViewController:viewController animated:YES completion: nil];
    else
    {
        MKWindowOptions *windowOptions = [MKWindowOptions new];
        windowOptions.windowRoot       = YES;
        return [self _presentViewControllerWindow:viewController windowOptions:windowOptions];
    }
    return [[MKDeferred resolved:viewController.context] promise];
}

- (MKPromise)_presentViewControllerWindow:(UIViewController<MKContextual> *)viewController
                            windowOptions:(MKWindowOptions *)windowOptions
{
    MKContext *context = self.composer.context;
    
    if (windowOptions.newWindow)
    {
        UIApplication       *application  = [UIApplication sharedApplication];
        UIWindow            *keyWindow    = application.keyWindow;
        MKContext           *childContext = [MKContextualHelper bindChildContextFrom:context toChild:viewController];
        __block UIWindow    *newWindow    = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        MKDefaultViewRegion *newRegion    = [[self.class alloc] initWithWindow:newWindow];
        [childContext addHandler:newRegion];
        
        [childContext subscribeDidEnd:^(id<MKContext> context) {
            [viewController.view removeFromSuperview];
            [keyWindow makeKeyWindow];
            [_window refreshOrientation];
            newWindow.hidden = YES;
            newWindow        = nil;
        }];
        
        newWindow.windowLevel = windowOptions.specified.windowLevel
                              ? windowOptions.windowLevel
                              : _window.windowLevel + 1;  // put overlay on top
        newWindow.rootViewController = viewController;
        [newWindow makeKeyAndVisible];
    }
    else if (windowOptions.windowRoot)
    {
        MKContext *rootContext     = [context unwindToRootContext];
        MKContext *childContext    = [MKContextualHelper bindChildContextFrom:rootContext toChild:viewController];
        _window.rootViewController = viewController;
        [childContext subscribeDidEnd:^(id<MKContext> context) {
            if (_window.rootViewController == viewController)
                _window.rootViewController = nil;
        }];
    }
    
    return [[MKDeferred resolved:viewController.context] promise];
}

@end
