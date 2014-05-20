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

#define kDefaultPerspective        (-1.0 / 200.0)
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
        _cubeAxis      = MKCubeTransitionAxisHorizontal;
        _rotateDegrees = kDefaultRotationDeg;
        _perspective   = kDefaultPerspective;
    }
    return self;
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
        [containerView addSubview:toView];
        return [self completeTransition:transitionContext];
        return;
    }
    
    NSInteger direction = self.isPresenting ? -1 : 1;
    CGFloat   angle     = direction * degreesToRadians(_rotateDegrees);
    CATransform3D viewFromTransform, viewToTransform;

    switch (_cubeAxis)
    {
        case MKCubeTransitionAxisHorizontal:
        {
            viewFromTransform           = CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
            viewToTransform             = CATransform3DMakeRotation(-angle, 0.0, 1.0, 0.0);
            toView.layer.anchorPoint    = CGPointMake(direction == 1 ? 0 : 1, 0.5);
            fromView.layer.anchorPoint  = CGPointMake(direction == 1 ? 1 : 0, 0.5);
            CGFloat tx                  = direction * (containerView.frame.size.width) / 2.0;
            containerView.transform     = CGAffineTransformMakeTranslation(tx, 0);
            break;
        }
            
        case MKCubeTransitionAxisVertical:
        {
            viewFromTransform          = CATransform3DMakeRotation(-angle, 1.0, 0.0, 0.0);
            viewToTransform            = CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
            toView.layer.anchorPoint   = CGPointMake(0.5, direction == 1 ? 0 : 1);
            fromView.layer.anchorPoint = CGPointMake(0.5, direction == 1 ? 1 : 0);
            CGFloat ty                 = direction * (containerView.frame.size.height) /2.0;
            containerView.transform    = CGAffineTransformMakeTranslation(0, ty);
            break;
        }
    }
    
    viewFromTransform.m34  = _perspective;
    viewToTransform.m34    = _perspective;
    toView.layer.transform = viewToTransform;
    
    //Create the shadow
    UIView *fromShadow     = [self addOpacityToView:fromView withColor:[UIColor blackColor]];
    UIView *toShadow       = [self addOpacityToView:toView withColor:[UIColor blackColor]];
    fromShadow.alpha       = 0.0;
    toShadow.alpha         = 1.0;
    
    //Add the to- view
    [containerView addSubview:toView];
    
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
        
        fromView.layer.transform = viewFromTransform;
        toView.layer.transform   = CATransform3DIdentity;
        fromShadow.alpha         = 1.0;
        toShadow.alpha           = 0.0;
        
    }
    completion:^(BOOL finished) {
        //Set the final position of every elements transformed
        containerView.transform    = CGAffineTransformIdentity;
        fromView.layer.transform   = CATransform3DIdentity;
        toView.layer.transform     = CATransform3DIdentity;
        fromView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        toView.layer.anchorPoint   = CGPointMake(0.5f, 0.5f);
        
        [fromShadow removeFromSuperview];
        [toShadow removeFromSuperview];
        
        BOOL cancelled = [transitionContext transitionWasCancelled];
        if (cancelled)
            [toView removeFromSuperview];
        else
            [fromView removeFromSuperview];
        
        [transitionContext completeTransition:!cancelled];
    }];
}

- (UIView *)addOpacityToView:(UIView *)view withColor:(UIColor *)theColor
{
    UIView *shadowView = [[UIView alloc] initWithFrame:view.bounds];
    [shadowView setBackgroundColor:[theColor colorWithAlphaComponent:0.8]];
    [view addSubview:shadowView];
    return shadowView;
}

@end
