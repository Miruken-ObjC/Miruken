//
//  MKPullToRefreshMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPullToRefreshMixin.h"
#import "MKPullToRefreshView.h"
#import "MKDeferred.h"
#import <objc/runtime.h>

#define kPullToRefreshViewTag           (-1000)
#define kDefaultMinTriggerRefreshOffset (75.0f)

typedef NS_ENUM(NSUInteger, MKPullToRefreshState) {
    MKPullToRefreshStateReady        = 0,
    MKPullToRefreshStateDragging     = (1 << 1),
    MKPullToRefreshStateDecelerating = (1 << 2),
    MKPullToRefreshStateRefreshing   = (1 << 3),
};

@interface MKPullToRefreshMixin() <MKPullToRefreshDelegate>
@end

@implementation MKPullToRefreshMixin

+ (void)verifyCanMixIntoClass:(Class)class
{
    if ([class conformsToProtocol:@protocol(MKPullToRefreshDelegate)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKPullToRefreshMixin requires the target class "
                                               "to conform to the PullToRefreshDelegate protocol."
                                     userInfo:nil];
}

#pragma mark - PullToRefreshDelegate

- (MKPromise)performRefresh
{
    return [[MKDeferred resolved] promise];
}

- (UIView<MKPullToRefresh> *)pullToRefreshViewInScrollView:(UIScrollView *)scrollView
{
    return [[MKPullToRefreshView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self MKPullToRefresh_scrollViewDidScroll:scrollView];
}

- (void)swizzlePullToRefresh_scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self MKPullToRefresh_scrollViewDidScroll:scrollView];
    [self swizzlePullToRefresh_scrollViewDidScroll:scrollView];
}

- (void)MKPullToRefresh_scrollViewDidScroll:(UIScrollView *)scrollView
{
    MKPullToRefreshState state = [self MKPullToRefresh_state];
    CGFloat              top   = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    if (scrollView.isTracking && scrollView.isDragging && (scrollView.isDecelerating == NO) &&
        (top <= 0.0) && (state == MKPullToRefreshStateReady) &&
        ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y > 0))
        [self setMKPullToRefresh_state:state = MKPullToRefreshStateDragging];
    
    UIView<MKPullToRefresh> *pullToRefreshView =
        (UIView<MKPullToRefresh> *)[scrollView viewWithTag:kPullToRefreshViewTag];
    
    if (state & MKPullToRefreshStateDecelerating)
    {
        CGFloat pullHeight = CGRectGetHeight(pullToRefreshView.frame);
        if (top >= -pullHeight)
        {
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y       = -pullHeight - scrollView.contentInset.top;
            [self setMKPullToRefresh_state:state = (state & ~MKPullToRefreshStateDecelerating)];
            [scrollView setContentOffset:contentOffset animated:YES];
        }
    }
    else if (top >= 0 || state == MKPullToRefreshStateReady)
        return;
    
    if (pullToRefreshView == nil)
    {
        pullToRefreshView     = [self pullToRefreshViewInScrollView:scrollView];
        pullToRefreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        pullToRefreshView.tag = kPullToRefreshViewTag;
        [scrollView addSubview:pullToRefreshView];
        [pullToRefreshView sizeToFit];
    }
    
    CGFloat pullPercent = 1.0;
    if (pullToRefreshView.mode & MKPullToRefreshModeRefreshing)
    {
        pullPercent = MIN(MAX(top / -[pullToRefreshView sizeThatFits:CGSizeZero].height, 0), 1.0);
    }
    else
    {
        CGFloat minOffsetTrigger = [self respondsToSelector:@selector(minTriggerRefreshOffset)]
        ? [self minTriggerRefreshOffset]
        : kDefaultMinTriggerRefreshOffset;
        pullPercent              = MIN(MAX(top /-minOffsetTrigger, 0.0), 1.0);
        pullToRefreshView.mode   = pullPercent >= 1.0 ? MKPullToRefreshModeRelease : MKPullToRefreshModePull;
    }
    
    if ([pullToRefreshView respondsToSelector:@selector(pullPercent)])
        pullToRefreshView.pullPercent = pullPercent;
    
    pullToRefreshView.frame = ({
        CGRect frame     = pullToRefreshView.frame;
        frame.origin.x   = scrollView.contentOffset.x;
        frame.origin.y   = top;
        frame.size.width = CGRectGetWidth(scrollView.frame);
        frame;
    });
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self MKPullToRefresh_scrollViewWillEndDragging:scrollView withVelocity:velocity
                                targetContentOffset:targetContentOffset];
}

- (void)swizzlePullToRefresh_scrollViewWillEndDragging:(UIScrollView *)scrollView
                                          withVelocity:(CGPoint)velocity
                                   targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self MKPullToRefresh_scrollViewWillEndDragging:scrollView withVelocity:velocity
                                targetContentOffset:targetContentOffset];
    [self swizzlePullToRefresh_scrollViewWillEndDragging:scrollView withVelocity:velocity
                                     targetContentOffset:targetContentOffset];
}

- (void)MKPullToRefresh_scrollViewWillEndDragging:(UIScrollView *)scrollView
                                     withVelocity:(CGPoint)velocity
                              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    UIView<MKPullToRefresh> *pullToRefreshView =
        (UIView<MKPullToRefresh> *)[scrollView viewWithTag:kPullToRefreshViewTag];
    
    if (pullToRefreshView && pullToRefreshView.mode == MKPullToRefreshModeRelease)
    {
        pullToRefreshView.mode = MKPullToRefreshModeRefreshing;
        [self setMKPullToRefresh_state:MKPullToRefreshStateDecelerating | MKPullToRefreshStateRefreshing];
        [[self performRefresh] always:^{
            [self setMKPullToRefresh_state:MKPullToRefreshStateReady];
            [pullToRefreshView removeFromSuperview];
            if ([self respondsToSelector:@selector(scrollToTopAfterRefresh)] == NO ||
                [self scrollToTopAfterRefresh]) {
                CGPoint offset = scrollView.contentOffset;
                offset.y       = -scrollView.contentInset.top;
                [scrollView setContentOffset:offset animated:YES];
            }
        }];
    }
}

- (BOOL)MKPullToRefresh_state
{
    NSNumber *state = objc_getAssociatedObject(self, @selector(MKPullToRefresh_state));
    return state ? [state unsignedIntegerValue] : MKPullToRefreshStateReady;
}

- (void)setMKPullToRefresh_state:(MKPullToRefreshState)state
{
    NSNumber *pullState = (state != MKPullToRefreshStateReady) ? @(state) : nil;
    objc_setAssociatedObject(self, @selector(MKPullToRefresh_state), pullState, OBJC_ASSOCIATION_COPY);;
}

@end
