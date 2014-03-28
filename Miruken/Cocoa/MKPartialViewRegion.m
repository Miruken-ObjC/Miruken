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
#import "MKContextualHelper.h"
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
    UIViewController *_controller;
}

- (MKContext *)context
{
    if (_context == nil)
    {
        UIViewController<MKContextual> *owningController = [self owningViewController];
        _context                                         = [owningController.context newChildContext];
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
        if (self.context != composer && presentationPolicy.definesPresentationContext == NO)
        {
            UIViewController       *owner = [composer getClass:UIViewController.class orDefault:nil];
            UINavigationController *navigationController = owner.navigationController;
            
            if (navigationController)
            {
                [navigationController pushViewController:viewController animated:YES];
                return;
            }
        }
        
        UIViewController *fromController = _controller;
        
        [self removePartialController];
        [self addPartialController:viewController];
        
        if (_controller && _controller.transitioningDelegate)
        {
            MKPartialTransitionContext *partialTransition =
            [MKPartialTransitionContext partialRegion:self
                                   fromViewController:fromController
                                     toViewController:_controller];
            
            id<UIViewControllerAnimatedTransitioning> transitionController =
            [viewController.transitioningDelegate
             animationControllerForPresentedController:_controller
             presentingController:fromController
             sourceController:fromController];
            
            [transitionController animateTransition:partialTransition];
        }
        else
            [self addSubview:_controller.view];
        return;
    }
    
    [self notHandled];
}

- (void)addPartialController:(UIViewController *)partialController
{
    if (partialController)
    {
        _controller                        = partialController;
        UIViewController *owningController = [self owningViewController];
        MKContext        *partialContext   = [MKContextualHelper bindChildContextFrom:self.context
                                                                              toChild:_controller];
        [_controller       willMoveToParentViewController:owningController];
        [owningController  addChildViewController:partialController];
        [partialController didMoveToParentViewController:owningController];
        [self fillPartialFrame];
        
        @weakify(self);
        [partialContext subscribeDidEnd:^(id<MKContext> context) {
            @strongify(self);
            [self removePartialController];
        }];
    }
}

- (void)removePartialController
{
    if (_controller)
    {
        [_controller  willMoveToParentViewController:nil];
        [_controller  removeFromParentViewController];
        [_controller.view removeFromSuperview];
        [_controller  didMoveToParentViewController:nil];
        _controller   = nil;
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

- (void)fillPartialFrame
{
    if (_controller)
    {
        CGRect partialFrame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        if (CGRectEqualToRect(_controller.view.frame, partialFrame) == NO)
            _controller.view.frame = partialFrame;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self fillPartialFrame];
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
    [_partialRegion addSubview:_toViewController.view];
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