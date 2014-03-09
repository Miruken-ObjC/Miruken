//
//  MKDefaultViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDefaultViewRegion.h"
#import "MirukenContext.h"

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

- (void)presentViewController:(UIViewController *)viewController
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
}

- (void)presentNextViewController:(UIViewController *)viewController
{
    MKCallbackHandler *composer = self.composer;
    UIViewController  *owner    = [composer getClass:UIViewController.class orDefault:nil];
    UINavigationController *navigationController = owner.navigationController;
    
    if (navigationController)
        [navigationController pushViewController:viewController animated:YES];
    else
        [self presentViewController:viewController];
}

@end
