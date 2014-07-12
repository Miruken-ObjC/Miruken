//
//  MKVerticalLinesTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 7/6/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by by F Christian Inkster on 16/09/13.
//

#import "MKVerticalLinesTransition.h"

#define kDefaultLineWidth        (4.0)
#define kAnimationDurationStep1  (0.01)
#define kAnimationDurationStep2  (4.0)

@implementation MKVerticalLinesTransition

- (id)init
{
    if (self = [super init])
    {
        _lineWidth             = kDefaultLineWidth;
        self.animationDuration = kAnimationDurationStep1 + kAnimationDurationStep2;
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
    
    // lets get a snapshot of the from view
    UIView *fromSnapshot  = [fromView snapshotViewAfterScreenUpdates:NO];
    
    // cut it into vertical slices
    NSArray *fromSlices   = [self cutView:fromSnapshot];
    
    // add the slices to the content view.
    for (UIView *slice in fromSlices)
        [containerView addSubview:slice];
    
    toView.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:toView];
    
    CGFloat toViewStartY  = toView.frame.origin.y;
    toView.alpha          = 0.0;
    fromView.hidden       = YES;

    [UIView animateWithDuration:kAnimationDurationStep1 delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
        // hack to get the incoming view to render before I snapshot it.
    } completion:^(BOOL finished) {
        toView.alpha       = 1.0;
        UIView *toSnapshot = [toView snapshotViewAfterScreenUpdates:YES];
        
        // cut it into vertical slices
        NSArray *toSlices  = [self cutView:toSnapshot];
        
        // move the slices in to start position (mess them up)
        [self repositionViewSlices:toSlices moveFirstFrameUp:NO];
        
        // add the slices to the content view.
        for (UIView *slice in toSlices)
            [containerView addSubview:slice];
        toView.hidden = YES;
        
        [UIView animateWithDuration:kAnimationDurationStep2 delay:0
             usingSpringWithDamping:0.8 initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self repositionViewSlices:fromSlices moveFirstFrameUp:YES];
            [self resetViewSlices:toSlices toYOrigin:toViewStartY];
        } completion:^(BOOL finished) {
            fromView.hidden = NO;
            toView.hidden   = NO;
            [toView setNeedsUpdateConstraints];
            for (UIView *slice in [fromSlices arrayByAddingObjectsFromArray:toSlices])
                [slice removeFromSuperview];
            BOOL cancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancelled];
        }];
    }];
}

-(NSMutableArray *)cutView:(UIView *)view
{
    CGFloat         width      = CGRectGetWidth(view.frame);
    CGFloat         lineHeight = CGRectGetHeight(view.frame);
    NSMutableArray *lineSlices = [NSMutableArray array];
    
    for (CGFloat x = 0; x < width; x += _lineWidth)
    {
        CGRect subrect = CGRectMake(x, 0, _lineWidth, lineHeight);
        UIView *subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO
                                                    withCapInsets:UIEdgeInsetsZero];
        subsnapshot.frame   = subrect;
        
        [lineSlices addObject:subsnapshot];
    }
    
    return lineSlices;
}

- (void)repositionViewSlices:(NSArray *)views moveFirstFrameUp:(BOOL)startUp
{
    BOOL up = startUp;
    for (UIView *slice in views)
    {
        CGRect frame    = slice.frame;
        CGFloat height  = CGRectGetHeight(frame) * [self randomFloatBetween:1.0 and:4.0];
        frame.origin.y += up ? -height : height;
        slice.frame     = frame;
        up = !up;
    }
}

- (void)resetViewSlices:(NSArray *)views toYOrigin:(CGFloat)y
{
    for (UIView *slice in views)
    {
        CGRect frame   = slice.frame;
        frame.origin.y = y;
        slice.frame    = frame;
    }
}

@end
