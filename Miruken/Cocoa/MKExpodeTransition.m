//
//  MKExpodeTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Colin Eberhardt on 09/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "MKExpodeTransition.h"

#define kExplodeAnimationDuration (1.0f)

@implementation MKExpodeTransition

- (id)init
{
    if (self = [super init])
        self.animationDuration = kExplodeAnimationDuration;
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView     = [transitionContext containerView];
    UIView *fromView          = fromViewController.view;
    UIView *toView            = toViewController.view;

    if (fromView == nil)
    {
        [self completeTransition:transitionContext];
        return;
    }
    
    if (toView)
    {
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
    }

    CGSize          size      = toView ? toView.frame.size : fromView.frame.size;
    CGFloat         xFactor   = 10.0f;
    CGFloat         yFactor   = xFactor * size.height / size.width;
    
    // snapshot the from view, this makes subsequent snaphots more performant
    UIView *fromViewSnapshot  = [fromView snapshotViewAfterScreenUpdates:NO];
    [fromView removeFromSuperview];
    
    // create a snapshot for each of the exploding pieces
    NSMutableArray *snapshots = [NSMutableArray new];
    for (CGFloat x = 0; x < size.width; x += size.width / xFactor)
    {
        for (CGFloat y = 0; y < size.height; y += size.height / yFactor)
        {
            CGRect  snapshotRegion = CGRectMake(x, y, size.width / xFactor, size.height / yFactor);
            UIView *snapshot       = [fromViewSnapshot resizableSnapshotViewFromRect:snapshotRegion
                                                                  afterScreenUpdates:NO
                                                                       withCapInsets:UIEdgeInsetsZero];
            snapshot.frame         = snapshotRegion;
            [containerView addSubview:snapshot];
            [snapshots addObject:snapshot];
        }
    }
    
    [containerView sendSubviewToBack:fromView];
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        for (UIView *view in snapshots)
        {
            CGFloat xOffset = [self randomFloatBetween:-100.0 and:100.0];
            CGFloat yOffset = [self randomFloatBetween:-100.0 and:100.0];
            view.frame      = CGRectOffset(view.frame, xOffset, yOffset);
            view.alpha      = 0.0;
            CGFloat angle   = [self randomFloatBetween:-10.0 and:10.0];
            view.transform  = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 0.0, 0.0);
        }
    } completion:^(BOOL finished) {
        for (UIView *view in snapshots)
            [view removeFromSuperview];
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

- (CGFloat)randomFloatBetween:(float)smallNumber and:(float)bigNumber
{
    CGFloat diff = bigNumber - smallNumber;
    return (((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

@end