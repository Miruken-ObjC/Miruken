//
//  MKPartialViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPartialViewRegion.h"
#import "MKDynamicCallbackHandler.h"
#import "MKContextual.h"
#import "MKPresentationPolicy.h"
#import "MKContext+Subscribe.h"
#import "NSObject+NotHandled.h"
#import "MKCallbackHandler+Resolvers.h"
#import "NSObject+Context.h"
#import "EXTScope.h"

@interface MKPartialTransitionContext : NSObject <UIViewControllerContextTransitioning>

+ (instancetype)partialRegion:(MKPartialViewRegion *)partialRegion
           fromViewController:(UIViewController *)fromViewController
             toViewController:(UIViewController *)toViewController;

@end

@implementation MKPartialViewRegion
{
    MKContext        *_context;
    __weak UIView    *_partialView;
    UIViewController *_controller;
}

- (MKContext *)context
{
    if (_context == nil)
    {
        UIViewController<MKContextual> *owningController = [self owningViewController];
        _context                                         = [owningController.context newChildContext];
        
        @weakify(self);
        [_context subscribeDidEnd:^(id<MKContext> context) {
            @strongify(self);
            [self removePartialController];
        }];
        
        [_context addHandler:[MKDynamicCallbackHandler delegateTo:self]];
    }
    return _context;
}

- (id)controller
{
    return _controller;
}

#pragma mark - MKViewRegion

- (void)presentViewController:(UIViewController *)viewController
{
    BOOL                  isModal            = NO;
    MKCallbackHandler    *composer           = self.composer;
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    if ([composer handle:presentationPolicy greedy:YES])
    {
        [presentationPolicy applyToViewController:viewController];
        isModal = presentationPolicy.isModal;
    }
    
    if (isModal == NO)
    {
        if (presentationPolicy.definesPresentationContext == NO)
        {
            UIViewController       *owner = [composer getClass:UIViewController.class orDefault:nil];
            UINavigationController *navigationController = owner.navigationController;
            
            if (navigationController)
            {
                [navigationController pushViewController:viewController animated:YES];
                return;
            }
        }

        if (viewController.transitioningDelegate && _controller && viewController)
        {
            MKPartialTransitionContext *partialTransition =
                [MKPartialTransitionContext partialRegion:self
                                       fromViewController:_controller
                                         toViewController:viewController];
            
            id<UIViewControllerAnimatedTransitioning> transitionController =
                [viewController.transitioningDelegate
                    animationControllerForPresentedController:viewController
                                         presentingController:_controller
                                             sourceController:_controller];
            
            [transitionController animateTransition:partialTransition];
        }
        else
        {
            [self removePartialController];
            [self addPartialController:viewController];
        }
    }
    else
        [self notHandled];
}

- (void)addPartialController:(UIViewController *)partialController
{
    if (partialController)
    {
        UIViewController *owningController = [self owningViewController];
        _controller                        = partialController;
        [_controller       willMoveToParentViewController:owningController];
        [owningController  addChildViewController:partialController];
        [partialController didMoveToParentViewController:owningController];
        [self addSubview:_partialView      = partialController.view];
    }
}

- (void)removePartialController
{
    if (_controller)
    {
        [_controller  willMoveToParentViewController:nil];
        [_controller  removeFromParentViewController];
        [_partialView removeFromSuperview];
        [_controller  didMoveToParentViewController:nil];
        _controller   = nil;
        _partialView  = nil;
    }
}

- (UIViewController<MKContextual> *)owningViewController
{
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
        if ([nextResponder isKindOfClass:UIViewController.class])
            return nextResponder;
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_partialView)
    {
        CGRect partialFrame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        if (CGRectEqualToRect(_partialView.frame, partialFrame) == NO)
            _partialView.frame = partialFrame;
    }
}

- (void)dealloc
{
    [_context end];
    _context = nil;
}

@end

#pragma mark - MKPartialTransitionContext

@implementation MKPartialTransitionContext
{
    __weak MKPartialViewRegion *_partialRegion;
    __weak UIViewController    *_fromViewController;
    __weak UIViewController    *_toViewController;
}

+ (instancetype)partialRegion:(MKPartialViewRegion *)partialRegion
           fromViewController:(UIViewController *)fromViewController
             toViewController:(UIViewController *)toViewController
{
    MKPartialTransitionContext *partialContext = [MKPartialTransitionContext new];
    partialContext->_partialRegion             = partialRegion;
    partialContext->_fromViewController        = fromViewController;
    partialContext->_toViewController          = toViewController;
    return partialContext;
}

- (UIView *)containerView
{
    return _partialRegion;
}

- (BOOL)isAnimated
{
    return YES;
}

- (BOOL)isInteractive
{
    return NO;
}

- (BOOL)transitionWasCancelled
{
    return NO;
}

- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationNone;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
}

- (void)finishInteractiveTransition
{
}

- (void)cancelInteractiveTransition
{
}

- (void)completeTransition:(BOOL)didComplete
{
    [_partialRegion removePartialController];
    [_partialRegion addPartialController:_toViewController];
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    if ([key isEqualToString:UITransitionContextToViewControllerKey])
        return _toViewController;
    else if ([key isEqualToString:UITransitionContextFromViewControllerKey])
        return _fromViewController;
    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    return CGRectZero;
}

@end