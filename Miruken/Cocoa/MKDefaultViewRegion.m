//
//  MKDefaultViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDefaultViewRegion.h"
#import "MKContextualHelper.h"
#import "MKPresentationPolicy.h"
#import "MKContext+Subscribe.h"
#import "MKCallbackHandler+Resolvers.h"
#import "NSObject+Context.h"
#import "MKDeferred.h"

@implementation MKDefaultViewRegion
{
    UIWindow *_window;
}
- (id)initWithWindow:(UIWindow *)window
{
    if (self = [super init])
        _window = window;
    return self;
}

#pragma mark - MKViewRegion

- (id<MKPromise>)presentViewController:(UIViewController<MKContextual> *)viewController
{
    BOOL                  isModal            = NO;
    MKCallbackHandler    *composer           = self.composer;
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    if ([composer handle:presentationPolicy greedy:YES])
    {
        [presentationPolicy applyPolicyToViewController:viewController];
        isModal = presentationPolicy.isModal;
    }
    
    if (presentationPolicy.isModal == NO)
    {
        UIViewController       *owner = [composer getClass:UIViewController.class orDefault:nil];
        UINavigationController *navigationController = owner.navigationController;
        
        if (navigationController)
        {
            [navigationController pushViewController:viewController animated:YES];
            return [[MKDeferred resolved:viewController.context] promise];
        }
    }
    
    return [self _presentViewControllerModally:viewController];
}

- (id<MKPromise>)_presentViewControllerModally:(UIViewController<MKContextual> *)viewController
{
    MKCallbackHandler *composer = self.composer;
    [MKContextualHelper bindChildContextFrom:composer toChild:viewController];
    UIViewController  *owner    = [composer getClass:UIViewController.class orDefault:nil];
    if (owner == nil)
        owner = _window.rootViewController;
    if (owner)
        [owner presentViewController:viewController animated:YES completion: nil];
    else
    {
        _window.rootViewController = viewController;
        if ([viewController respondsToSelector:@selector(context)])
            [[(id<MKContextual>)viewController context] subscribeDidEnd:^(id<MKContext> context) {
                if (_window.rootViewController == viewController)
                    _window.rootViewController = nil;
            }];
    }
    return [[MKDeferred resolved:viewController.context] promise];
}

@end
