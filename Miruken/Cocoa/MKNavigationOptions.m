//
//  MKNavigationOptions.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKNavigationOptions.h"
#import "MKNavigationTransitionWrapper.h"
#import <objc/runtime.h>

@implementation MKNavigationOptions

- (void)applyPolicyToViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:UINavigationController.class] == NO)
        return;
    
    if (_transition)
    {
        UIViewController *dummyController = [UIViewController new];
        [_transition applyPolicyToViewController:dummyController];
        
        if (dummyController.transitioningDelegate)
        {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            MKNavigationTransitionWrapper *navigationDelegate = [MKNavigationTransitionWrapper
                                   wrapNavigation:navigationController.delegate
                                   withTransition:dummyController.transitioningDelegate];
            // Retain the MKNavigationTransitionWrapper in the UINavigationController
            objc_setAssociatedObject(viewController, _cmd, navigationDelegate, OBJC_ASSOCIATION_RETAIN);
            navigationController.delegate = navigationDelegate;
        }
    }
}

- (void)mergeIntoOptions:(id<MKPresentationOptions>)otherOptions
{
    if ([otherOptions isKindOfClass:self.class] == NO)
        return;
    
    if (_transition)
    {
        MKNavigationOptions *navigationOptions = otherOptions;
        if (navigationOptions.transition == nil)
            navigationOptions.transition = [MKTransitionOptions new];
        [_transition mergeIntoOptions:navigationOptions.transition];
    }
}

@end
