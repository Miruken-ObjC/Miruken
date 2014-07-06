//
//  MKHorizonatalLinesTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 7/6/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by by F Christian Inkster on 16/09/13.
//

#import "MKHorizonatalLinesTransition.h"

#define kDefaultLineHeight       (4.0)
#define kAnimationDurationStep1  (0.01)
#define kAnimationDurationStep2  (4.70)

@implementation MKHorizonatalLinesTransition

- (id)init
{
    if (self = [super init])
    {
        _lineHeight            = kDefaultLineHeight;
        self.animationDuration = kAnimationDurationStep1 + kAnimationDurationStep2;
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView   = [transitionContext containerView];
    UIView *fromView        = fromViewController.view;
    UIView *toView          = toViewController.view;
    
    // lets get a snapshot of the outgoing view
    UIView *fromSnapshot    = [fromView snapshotViewAfterScreenUpdates:NO];
    
    // cut it into vertical slices
    NSArray *outgoingSlices = [self cutView:fromSnapshot yOffset:fromView.frame.origin.y];
    
    // add the slices to the content view.
    for (UIView *slice in outgoingSlices)
        [containerView addSubview:slice];
    
    toView.frame            = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:toView];

    CGFloat toViewStartX    = toView.frame.origin.x;
    toView.alpha            = 0.0;
    fromView.hidden         = YES;
    
    [UIView animateWithDuration:kAnimationDurationStep1 delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
        // hack to get the incoming view to render before I snapshot it.
    } completion:^(BOOL finished) {
        toView.alpha        = 1.0;
        UIView *toSnapshot  = [toView snapshotViewAfterScreenUpdates:YES];
        
        // cut it into vertical slices
        NSArray *incomingSlices = [self cutView:toSnapshot yOffset:toView.frame.origin.y];
        
        // move the slices in to start position (incoming comes from the right)
        [self repositionViewSlices:incomingSlices moveLeft:!self.isPresenting];
        
        // add the slices to the content view.
        for (UIView *slice in incomingSlices)
            [containerView addSubview:slice];

        toView.hidden = YES;
        
        [UIView animateWithDuration:kAnimationDurationStep2 delay:0
             usingSpringWithDamping:0.8 initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self repositionViewSlices:outgoingSlices moveLeft:self.isPresenting];
            [self resetViewSlices:incomingSlices toXOrigin:toViewStartX];
        } completion:^(BOOL finished) {
            fromView.hidden = NO;
            toView.hidden   = NO;
            [toView setNeedsUpdateConstraints];
            for (UIView *slice in incomingSlices)
                [slice removeFromSuperview];
            for (UIView *slice in outgoingSlices)
                [slice removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }];
}

- (NSMutableArray *)cutView:(UIView *)view yOffset:(float)yOffset
{
    CGFloat         maxY       = CGRectGetMaxY(view.frame);
    CGFloat         height     = CGRectGetHeight(view.frame);
    CGFloat         lineWidth  = CGRectGetWidth(view.frame);
    NSMutableArray *lineSlices = [NSMutableArray array];
    
    for (CGFloat y = 0; y < height; y += _lineHeight)
    {
        CGRect  subrect     = CGRectMake(0, y, lineWidth, _lineHeight);
        if (CGRectGetMaxY(subrect) > maxY)
            subrect.size.height -= (CGRectGetMaxY(subrect) - maxY);
        UIView *subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO
                                                    withCapInsets:UIEdgeInsetsZero];
        subrect.origin.y   += yOffset;
        subsnapshot.frame   = subrect;
        
        [lineSlices addObject:subsnapshot];
    }
    
    return lineSlices;
}

- (void)repositionViewSlices:(NSArray *)views moveLeft:(BOOL)left
{
    for (UIView *slice in views)
    {
        CGRect frame    = slice.frame;
        CGFloat width   = CGRectGetWidth(frame) * [self randomFloatBetween:1.0 and:8.0];
        frame.origin.x += left ? -width : width;
        slice.frame     = frame;
    }
}

- (void)resetViewSlices:(NSArray *)views toXOrigin:(CGFloat)x
{
    for (UIView *slice in views)
    {
        CGRect frame   = slice.frame;
        frame.origin.x = x;
        slice.frame    = frame;
    }
}

@end
