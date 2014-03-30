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
    NSArray          *_constraints;
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
    MKCallbackHandler    *composer              = self.composer;
    MKPresentationPolicy *presentationPolicy    = [MKPresentationPolicy new];
    BOOL                  hasPresentationPolicy = NO;
    
    if ((hasPresentationPolicy = [composer handle:presentationPolicy greedy:YES]))
        [presentationPolicy applyPolicyToViewController:viewController];
    
    if (hasPresentationPolicy && presentationPolicy.isModal == NO)
    {
        if (self.context != composer)
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
        
        [self removePartialControllerAnimated:NO];
        [self addPartialController:viewController];
        [self applyConstraintsToView:_controller.view policy:presentationPolicy];
        
        if (_controller && _controller.transitioningDelegate)
        {
            MKPartialTransitionContext *partialTransition =
            [MKPartialTransitionContext partialRegion:self
                                   fromViewController:fromController
                                     toViewController:_controller];
            
            id<UIViewControllerAnimatedTransitioning> transitionController =
            [_controller.transitioningDelegate
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
        
        @weakify(self);
        [partialContext subscribeDidEnd:^(id<MKContext> context) {
            @strongify(self);
            [self removePartialControllerAnimated:YES];
        }];
    }
}

- (void)removePartialControllerAnimated:(BOOL)animated
{
    if (_controller)
    {
        if (animated && _controller.transitioningDelegate)
        {
            MKPartialTransitionContext *partialTransition =
            [MKPartialTransitionContext partialRegion:self
                                   fromViewController:_controller
                                     toViewController:nil];
            
            id<UIViewControllerAnimatedTransitioning> transitionController =
            [_controller.transitioningDelegate animationControllerForDismissedController:_controller];
            [transitionController animateTransition:partialTransition];
        }
        [_controller  willMoveToParentViewController:nil];
        [_controller  removeFromParentViewController];
        [_controller.view removeFromSuperview];
        [_controller  didMoveToParentViewController:nil];
        _controller   = nil;
    }
    
    if (_constraints)
        [self removeConstraints:_constraints];
}

- (UIViewController<MKContextual> *)owningViewController
{
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
        if ([nextResponder isKindOfClass:UIViewController.class])
            return nextResponder;
    return nil;
}

- (NSArray *)applyConstraintsToView:(UIView *)view policy:(MKPresentationPolicy *)policy
{
    NSArray      *constraints;
    UIEdgeInsets  edgeInsets = policy.edgeInsets;
    NSDictionary *metrics    = @{ @"top"   : @(edgeInsets.top),
                                  @"left"  : @(edgeInsets.left),
                                  @"bottom": @(edgeInsets.bottom),
                                  @"right" : @(edgeInsets.right)
                                  };
    NSDictionary *views      = NSDictionaryOfVariableBindings(view);
    
     constraints = @[
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[view]-right-|"
                                                options:0 metrics:metrics views:views],
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[view]-bottom-|"
                                                options:0 metrics:metrics views:views]
        ];
    [self addConstraints:constraints];
    return constraints;
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
    return vc == _toViewController
         ? CGRectZero
         : _fromViewController.view.frame;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    return vc == _toViewController
         ? _toViewController.view.frame
         : CGRectZero;
}

@end