//
//  MKNatGeoTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/24/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKNatGeoTransition.h"

#define kNatGeoAnimationDuration   (1.4f)
#define kDefaultFirstPartRatio     (0.8f);
#define kDefaultPerspective        (-1.0 / 500.0f)
#define degreesToRadians(degrees)  ((degrees) / 180.0 * M_PI)

@implementation MKNatGeoTransition
{
    CGFloat _firstPartRatio;
}

+ (instancetype)natGeoFirstPartRatio:(CGFloat)firstPartRatio
{
    if (firstPartRatio < 0 || firstPartRatio > 1)
       @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"firstPartRatio must be between 0 and 1"
                                         userInfo:nil];
    
    MKNatGeoTransition *natGeo = [self new];
    natGeo->_firstPartRatio    = firstPartRatio;
    return natGeo;
}

- (id)init
{
    if (self = [super init])
    {
        _firstPartRatio        = kDefaultFirstPartRatio;
        _perspective           = kDefaultPerspective;
        self.animationDuration = kNatGeoAnimationDuration;
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
    
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    
    CALayer        *fromLayer, *toLayer;
    NSTimeInterval  duration = [self transitionDuration:transitionContext];
    
    if (self.isPresenting)
    {
        fromView.userInteractionEnabled = NO;
        fromLayer                       = fromView.layer;
        toLayer                         = toView.layer;
        
        // Change anchor point and reposition it.
        CGRect oldFrame                 = fromLayer.frame;
        fromLayer.anchorPoint           = CGPointMake(0.0f, 0.5f);
        fromLayer.frame                 = oldFrame;
        
        // Reset to initial transform
        sourceFirstTransform(fromLayer, _perspective);
        destinationFirstTransform(toLayer, _perspective);
        
        //Perform animation
        [UIView animateKeyframesWithDuration:duration delay:0.0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
              [UIView addKeyframeWithRelativeStartTime:0.0f
                                      relativeDuration:1.0f
                                            animations:^{
                                                destinationLastTransform(toLayer, _perspective);
                                            }];
              
              [UIView addKeyframeWithRelativeStartTime:(1.0f - _firstPartRatio)
                                      relativeDuration:_firstPartRatio
                                            animations:^{
                                                sourceLastTransform(fromLayer, _perspective);
                                            }];
              
          } completion:^(BOOL finished) {
              BOOL cancelled = [transitionContext transitionWasCancelled];
              
              // Bring the from view back to the front and re-enable its user
              // interaction since the presentation has been cancelled
              if (cancelled)
              {
                  [containerView bringSubviewToFront:fromView];
                  fromView.userInteractionEnabled = YES;
              }
              
              fromView.layer.transform      = CATransform3DIdentity;
              toView.layer.transform        = CATransform3DIdentity;
              containerView.layer.transform = CATransform3DIdentity;
              [transitionContext completeTransition:!cancelled];
          }];
    }
    else
    {
        toView.userInteractionEnabled = YES;
        fromLayer                     = toView.layer;
        toLayer                       = fromView.layer;
        
        // Reset to initial transform
        sourceLastTransform(fromLayer, _perspective);
        destinationLastTransform(toLayer, _perspective);
        
        //Perform animation
        [UIView animateKeyframesWithDuration:duration delay:0.0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
              [UIView addKeyframeWithRelativeStartTime:0.0f
                                      relativeDuration:_firstPartRatio
                                            animations:^{
                                                sourceFirstTransform(fromLayer, _perspective);
                                            }];
              
              [UIView addKeyframeWithRelativeStartTime:0.0f
                                      relativeDuration:1.0f
                                            animations:^{
                                                destinationFirstTransform(toLayer, _perspective);
                                            }];
              
          } completion:^(BOOL finished) {
              BOOL cancelled = [transitionContext transitionWasCancelled];
              
              // Bring the from view back to the front and re-disable the user
              // interaction of the to view since the dismissal has been cancelled
              if (cancelled)
              {
                  [containerView bringSubviewToFront:fromView];
                  toViewController.view.userInteractionEnabled = NO;
              }
              
              fromView.layer.transform      = CATransform3DIdentity;
              toView.layer.transform        = CATransform3DIdentity;
              containerView.layer.transform = CATransform3DIdentity;
              [transitionContext completeTransition:!cancelled];
          }];
    }
}

#pragma mark - Required 3d Transform

static void sourceFirstTransform(CALayer *layer, CGFloat perspective)
{
    CATransform3D t = CATransform3DIdentity;
    t.m34           = perspective;
    t               = CATransform3DTranslate(t, 0.0f, 0.0f, 0.0f);
    layer.transform = t;
}

static void sourceLastTransform(CALayer *layer, CGFloat perspective)
{
    CATransform3D t = CATransform3DIdentity;
    t.m34           = perspective;
    t               = CATransform3DRotate(t, degreesToRadians(80), 0.0f, 1.0f, 0.0f);
    t               = CATransform3DTranslate(t, 0.0f, 0.0f, -30.0f);
    t               = CATransform3DTranslate(t, 170.0f, 0.0f, 0.0f);
    layer.transform = t;
}

static void destinationFirstTransform(CALayer *layer, CGFloat perspective)
{
    CATransform3D t = CATransform3DIdentity;
    t.m34           = perspective;
    // Rotate 5 degrees within the axis of z axis
    t               = CATransform3DRotate(t, degreesToRadians(5.0f), 0.0f, 0.0f, 1.0f);
    // Reposition toward to the left where it initialized
    t               = CATransform3DTranslate(t, 320.0f, -40.0f, 150.0f);
    // Rotate it -45 degrees within the y axis
    t               = CATransform3DRotate(t, degreesToRadians(-45), 0.0f, 1.0f, 0.0f);
    // Rotate it 10 degrees within thee x axis
    t               = CATransform3DRotate(t, degreesToRadians(10), 1.0f, 0.0f, 0.0f);
    layer.transform = t;
}

static void destinationLastTransform(CALayer *layer, CGFloat perspective)
{
    CATransform3D t = CATransform3DIdentity;
    t.m34           = perspective;
    // Rotate to 0 degrees within z axis
    t               = CATransform3DRotate(t, degreesToRadians(0), 0.0f, 0.0f, 1.0f);
    // Bring back to the final position
    t               = CATransform3DTranslate(t, 0.0f, 0.0f, 0.0f);
    // Rotate 0 degrees within y axis
    t               = CATransform3DRotate(t, degreesToRadians(0), 0.0f, 1.0f, 0.0f);
    // Rotate 0 degrees within  x axis
    t               = CATransform3DRotate(t, degreesToRadians(0), 1.0f, 0.0f, 0.0f);
    layer.transform = t;
}

@end
