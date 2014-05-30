//
//  MKNavigationTransitionWrapper.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKNavigationTransitionWrapper.h"

@implementation MKNavigationTransitionWrapper
{
    id<UINavigationControllerDelegate>        _navigation;
    id<UIViewControllerTransitioningDelegate> _transition;
}

+ (instancetype)wrapNavigation:(id<UINavigationControllerDelegate>)nav
                withTransition:(id<UIViewControllerTransitioningDelegate>)transition
{
    MKNavigationTransitionWrapper *wrapper = [self new];
    wrapper->_navigation                   = nav;
    wrapper->_transition                   = transition;
    return wrapper;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)
    navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    switch (operation) {
        case UINavigationControllerOperationPush:
            return [_transition animationControllerForPresentedController:toVC
                                                     presentingController:fromVC
                                                         sourceController:fromVC];
            
        case UINavigationControllerOperationPop:
            return [_transition animationControllerForDismissedController:fromVC];
            
        default:
            return nil;
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _navigation;
}

@end
