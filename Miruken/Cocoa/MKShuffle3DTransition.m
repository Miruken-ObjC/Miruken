//
//  MKShuffle3DTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/8/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Tyler Tillage on 7/3/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "MKShuffle3DTransition.h"

#define kSuffleAnimationDuration  (1.3f)
#define kDefaultPerspective       (-1.0 / 2000.0)

@implementation MKShuffle3DTransition

- (id)init
{
    if (self = [super init])
    {
        self.animationDuration = kSuffleAnimationDuration;
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
    
    if (fromView == nil || toView == nil)
    {
        [self completeTransition:transitionContext];
        return;
    }
 
    // Take a snapshot of the 'from' view
    UIView *fromSnapshot  = [fromView snapshotViewAfterScreenUpdates:NO];
    fromSnapshot.frame    = fromView.frame;
    [containerView insertSubview:fromSnapshot aboveSubview:fromView];
    [fromView removeFromSuperview];
    
    // Add the 'to' view to the hierarchy
    toView.frame          = fromSnapshot.frame;
    [containerView insertSubview:toView belowSubview:fromSnapshot];
    
    // The amount of horizontal movement need to fit the views side by side in the middle of the animation
    CGFloat width = floorf(fromSnapshot.frame.size.width / 2.0) + 5.0;
    
    // Animate using keyframe animations
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                   delay:0.0 options:0 animations:^{
        // Apply z-index translations to make the views move away from the user
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.20 animations:^{
            CATransform3D fromT          = CATransform3DIdentity;
            fromT.m34                    = _perspective;
            fromT                        = CATransform3DTranslate(fromT, 0.0, 0.0, -590.0);
            fromSnapshot.layer.transform = fromT;
            
            CATransform3D toT            = CATransform3DIdentity;
            toT.m34                      = _perspective;
            toT                          = CATransform3DTranslate(fromT, 0.0, 0.0, -600.0);
            toView.layer.transform       = toT;
        }];
        
        // Adjust the views horizontally to clear each other
        [UIView addKeyframeWithRelativeStartTime:0.20 relativeDuration:0.20 animations:^{
            if (self.isPresenting)
            {
                fromSnapshot.layer.transform = CATransform3DTranslate(fromSnapshot.layer.transform,
                                                                      -width, 0.0, 0.0);
                toView.layer.transform = CATransform3DTranslate(toView.layer.transform, width, 0.0, 0.0);
            }
            else
            {
                fromSnapshot.layer.transform = CATransform3DTranslate(fromSnapshot.layer.transform, width, 0.0, 0.0);
                toView.layer.transform = CATransform3DTranslate(toView.layer.transform, -width, 0.0, 0.0);
            }
        }];
        
        // Pull the 'to' view in front of the 'from' view
        [UIView addKeyframeWithRelativeStartTime:0.40 relativeDuration:0.20 animations:^{
            fromSnapshot.layer.transform = CATransform3DTranslate(fromSnapshot.layer.transform, 0.0, 0.0, -200);
            toView.layer.transform = CATransform3DTranslate(toView.layer.transform, 0.0, 0.0, 500);
        }];
        
        // Adjust the views horizontally to place them back on top of each other
        [UIView addKeyframeWithRelativeStartTime:0.60 relativeDuration:0.20 animations:^{
            CATransform3D fromT = fromSnapshot.layer.transform;
            CATransform3D toT   = toView.layer.transform;
            if (self.isPresenting)
            {
                fromT = CATransform3DTranslate(fromT, floorf(width), 0.0, 200.0);
                toT   = CATransform3DTranslate(fromT, floorf(-(width * 0.03)) + 5.0, 0.0, 0.0);
            }
            else
            {
                fromT = CATransform3DTranslate(fromT, floorf(-width), 0.0, 200.0);
                toT   = CATransform3DTranslate(fromT, floorf(width * 0.03) + 5.0 , 0.0, 0.0);
            }
            fromSnapshot.layer.transform = fromT;
            toView.layer.transform       = toT;
        }];
        
        // Move the 'to' view to its final position
        [UIView addKeyframeWithRelativeStartTime:0.80 relativeDuration:0.20 animations:^{
            toView.layer.transform = CATransform3DIdentity;
        }];
    } completion:^(BOOL finished) {
        [fromSnapshot removeFromSuperview];
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

@end
