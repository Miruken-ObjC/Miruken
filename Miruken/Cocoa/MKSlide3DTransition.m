//
//  MKSlide3DTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/6/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Tyler Tillage on 7/3/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "MKSlide3DTransition.h"

#define kSlideAnimationDuration   (0.5f)
#define kDefaultPerspective       (-1.0 / 2000.0f)

@implementation MKSlide3DTransition

- (id)init
{
    if (self = [super init])
    {
        self.animationDuration = kSlideAnimationDuration;
        _perspective           = kDefaultPerspective;
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

    if (fromView)
        [containerView insertSubview:toView belowSubview:fromView];
    
    // 90 degrees away from the user
    CATransform3D t = CATransform3DRotate(CATransform3DIdentity, M_PI / 2.0, 0.0, 1.0, 0.0);
    t.m34           = _perspective;
    
    if (self.isPresenting)
    {
        [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:toView];
        if (fromView)
            [self setAnchorPoint:CGPointMake(0.0, 0.5) forView:fromView];
    }
    else
    {
        if (toView)
            [self setAnchorPoint:CGPointMake(0.0, 0.5) forView:toView];
        [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:fromView];
    }
    
    fromView.layer.zPosition = 2.0;
    toView.layer.zPosition   = 1.0;
    toView.layer.transform   = t;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.layer.transform = t;
        toView.layer.transform   = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        fromView.layer.zPosition = 0.0;
        toView.layer.zPosition   = 0.0;
        BOOL cancelled           = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin      = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin      = view.frame.origin;
    
    CGPoint transition     = {
        .x = newOrigin.x - oldOrigin.x,
        .y = oldOrigin.y - oldOrigin.y
    };
    
    view.center            = (CGPoint) {
        .x = view.center.x - transition.x,
        .y = view.center.y - transition.y
    };
}

@end
