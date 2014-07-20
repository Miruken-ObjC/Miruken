//
//  MKCubeTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Andrés Brun on 27/10/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "MKCubeTransition.h"

#define kDefaultPerspective        (-1.0 / 200.0f)
#define kDefaultRotationDeg        (90.0)
#define degreesToRadians(degrees)  ((degrees) / 180.0 * M_PI)

@implementation MKCubeTransition

+ (instancetype)cubeAxis:(MKCubeTransitionAxis)cubeAxis
{
    MKCubeTransition *cube = [self new];
    cube->_cubeAxis        = cubeAxis;
    return cube;
}

+ (instancetype)cubeAxis:(MKCubeTransitionAxis)cubeAxis rotateDegrees:(CGFloat)rotateDegrees
{
    MKCubeTransition *cube = [self new];
    cube->_rotateDegrees   = rotateDegrees;
    return cube;
}

- (id)init
{
    if (self = [super init])
    {
        _cubeAxis          = MKCubeTransitionAxisHorizontal;
        _rotateDegrees     = kDefaultRotationDeg;
        _perspective       = kDefaultPerspective;
        super.clipToBounds = NO;
    }
    return self;
}

- (void)setClipToBounds:(BOOL)clipToBounds
{
    // never clip
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;

    if (fromView == nil || toView == nil)
    {
        [self completeTransition:transitionContext];
        return;
    }

    [containerView addSubview:toView];

    NSInteger     direction = self.isPresenting ? -1 : 1;
    CGFloat       angle     = direction * degreesToRadians(_rotateDegrees);
    CATransform3D viewFromTransform, viewToTransform;

    // replace the from- and to- views with container views that include gradients
    UIView *fromShadow, *toShadow;
    UIView *fromContainer = [self _addShadowToView:fromView containerView:containerView
                                           reverse:self.isPresenting shadowView:&fromShadow];
    UIView *toContainer   = [self _addShadowToView:toView containerView:containerView
                                           reverse:!self.isPresenting shadowView:&toShadow];

    switch (_cubeAxis)
    {
        case MKCubeTransitionAxisHorizontal:
        {
            viewFromTransform               = CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
            viewToTransform                 = CATransform3DMakeRotation(-angle, 0.0, 1.0, 0.0);
            toContainer.layer.anchorPoint   = CGPointMake(direction == 1 ? 0 : 1, 0.5);
            fromContainer.layer.anchorPoint = CGPointMake(direction == 1 ? 1 : 0, 0.5);
            CGFloat tx                      = direction * (containerView.frame.size.width) / 2.0;
            containerView.transform         = CGAffineTransformMakeTranslation(tx, 0);
            break;
        }
            
        case MKCubeTransitionAxisVertical:
        {
            viewFromTransform               = CATransform3DMakeRotation(-angle, 1.0, 0.0, 0.0);
            viewToTransform                 = CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
            toContainer.layer.anchorPoint   = CGPointMake(0.5, direction == 1 ? 0 : 1);
            fromContainer.layer.anchorPoint = CGPointMake(0.5, direction == 1 ? 1 : 0);
            CGFloat ty                      = direction * (containerView.frame.size.height) /2.0;
            containerView.transform         = CGAffineTransformMakeTranslation(0, ty);
            break;
        }
    }
    
    viewFromTransform.m34       = _perspective;
    viewToTransform.m34         = _perspective;
    toContainer.layer.transform = viewToTransform;
    fromShadow.alpha            = 0.0;
    toShadow.alpha              = 1.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        switch (_cubeAxis) {
            case MKCubeTransitionAxisHorizontal:
            {
                CGFloat tx              = -direction * (containerView.frame.size.width) / 2.0;
                containerView.transform = CGAffineTransformMakeTranslation(tx, 0);
                break;
            }
                
            case MKCubeTransitionAxisVertical:
            {
                CGFloat ty              = -direction * (containerView.frame.size.height) /2.0;
                containerView.transform = CGAffineTransformMakeTranslation(0, ty);
                break;
            }
        }
        
        fromContainer.layer.transform = viewFromTransform;
        toContainer.layer.transform   = CATransform3DIdentity;
        fromShadow.alpha              = 1.0;
        toShadow.alpha                = 0.0;
    }
    completion:^(BOOL finished) {
        containerView.transform = CGAffineTransformIdentity;
        [fromContainer removeFromSuperview];
        [toContainer removeFromSuperview];

        BOOL cancelled = [transitionContext transitionWasCancelled];
        if (cancelled)
        {
            [containerView addSubview:fromView];
            [toView removeFromSuperview];
        }
        else
        {
            toView.frame = containerView.bounds;
            [containerView addSubview:toView];
            [fromView removeFromSuperview];
        }
        
        [transitionContext completeTransition:!cancelled];
    }];
}

- (UIView *)_addShadowToView:(UIView *)view containerView:(UIView *)containerView
                     reverse:(BOOL)reverse shadowView:(out UIView **)shadowView
{
    // create a view with the same frame
    UIView *viewWithShadow        = [[UIView alloc] initWithFrame:view.frame];
    
    // create a shadow
    *shadowView                   = [[UIView alloc] initWithFrame:view.bounds];
    (*shadowView).backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];

    // add the original view into our new view
    view.frame = view.bounds;
    [viewWithShadow addSubview:view];
    
    // place the shadow on top
    [viewWithShadow addSubview:*shadowView];
    
    [containerView addSubview:viewWithShadow];
    return viewWithShadow;
}

@end
