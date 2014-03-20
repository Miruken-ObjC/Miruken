//
//  MKPagingMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKPagingMixin.h"
#import "UIScrollView+Motion.h"
#import <objc/runtime.h>

#define kPagePercentageScrolled  30  // 30 percent

typedef NS_ENUM(NSUInteger, MKPagingMixinState) {
    MKPagingMixinStateScrollStarted = 0,
    MKPagingMixinStateScrollDragEnded,
    MKPagingMixinStateScrollBeginDecelerate,
    MKPagingMixinStateStateScrollHalted
};

@interface MKPagingMixin() <MKPagingDelegate>
@end

@implementation MKPagingMixin

+ (void)verifyCanMixIntoClass:(Class)targetClass
{
    if ([targetClass conformsToProtocol:@protocol(UIScrollViewDelegate)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKPagingMixin requires the target class "
                                               "to conform to the UIScrollViewDelegate protocol."
                                     userInfo:nil];
}

- (MKPagingMixinState)scrollState
{
    NSNumber *state = objc_getAssociatedObject(self, @selector(scrollState));
    return state ? (MKPagingMixinState)[state intValue] : MKPagingMixinStateStateScrollHalted;
}

- (void)setScrollState:(MKPagingMixinState)scrollState
{
    NSNumber *state = [NSNumber numberWithInt:scrollState];
    objc_setAssociatedObject(self, @selector(scrollState), state, OBJC_ASSOCIATION_RETAIN);
}

- (CGPoint)scrollOffset
{
    NSValue *offset = objc_getAssociatedObject(self, @selector(scrollOffset));
    return [offset CGPointValue];
}

- (void)setScrollOffset:(CGPoint)scrollOffset
{
    NSValue *offset = [NSValue valueWithCGPoint:scrollOffset];
    objc_setAssociatedObject(self, @selector(scrollOffset), offset, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewWillBeginDragging:scrollView];
}

- (void)swizzleScrolling_scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewWillBeginDragging:scrollView];
    [self swizzleScrolling_scrollViewWillBeginDragging:scrollView];
}

- (void)MKPaging_scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self scrollState] != MKPagingMixinStateScrollBeginDecelerate)
    {
        [self setScrollOffset:scrollView.contentOffset];
        [self setScrollState:MKPagingMixinStateScrollStarted];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewWillBeginDecelerating:scrollView];
}

- (void)swizzleScrolling_scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewWillBeginDecelerating:scrollView];
    [self swizzleScrolling_scrollViewWillBeginDecelerating:scrollView];
}

- (void)MKPaging_scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self setScrollState:MKPagingMixinStateScrollBeginDecelerate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self MKPaging_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)swizzleScrolling_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self MKPaging_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self swizzleScrolling_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)MKPaging_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self setScrollState: decelerate
        ? MKPagingMixinStateScrollDragEnded
        : MKPagingMixinStateStateScrollHalted];
    
    if (decelerate == NO)
    {
        if ([self respondsToSelector:@selector(scrollView:scrollingStopped:)])
            [(id<MKPagingDelegate>)self scrollView:scrollView scrollingStopped:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewDidEndDecelerating:scrollView];
}

- (void)swizzleScrolling_scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewDidEndDecelerating:scrollView];
    [self swizzleScrolling_scrollViewDidEndDecelerating:scrollView];
}

- (void)MKPaging_scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setScrollState:MKPagingMixinStateStateScrollHalted];
    if ([self respondsToSelector:@selector(scrollView:scrollingStopped:)])
        [(id<MKPagingDelegate>)self scrollView:scrollView scrollingStopped:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)swizzleScrolling_scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)MKPaging_scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self setScrollState:MKPagingMixinStateStateScrollHalted];
    if ([self respondsToSelector:@selector(scrollView:scrollingStopped:)])
        [(id<MKPagingDelegate>)self scrollView:scrollView scrollingStopped:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewDidScroll:scrollView complete:NO];
}

- (void)swizzleScrolling_scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self MKPaging_scrollViewDidScroll:scrollView complete:NO];
    [self swizzleScrolling_scrollViewDidScroll:scrollView];
}

- (void)MKPaging_scrollViewDidScroll:(UIScrollView *)scrollView complete:(BOOL)complete
{
    // Ignore scroll bounces at top and bottom
    
    if (scrollView.decelerating && (scrollView.isBeforeTop || scrollView.isAfterBottom))
        return;
    
    MKPagingDirection direction
                    = scrollView.contentOffset.y < [self scrollOffset].y
                    ? MKPagingDirectionDown
                    : MKPagingDirectionUp;
    
    [self MKPaging_scrollViewDidScroll:scrollView direction:direction complete:complete];
}

- (void)MKPaging_scrollViewDidScroll:(UIScrollView *)scrollView
                         direction:(MKPagingDirection)direction complete:(BOOL)complete
{
    if ([self respondsToSelector:@selector(scrollView:didScroll:)])
    {
        [(id<MKPagingDelegate>)self scrollView:scrollView didScroll:direction];
    }
    else if ([self respondsToSelector:@selector(scrollView:wantsPage:)])
    {
        if (direction == MKPagingDirectionDown)
        {
            CGFloat percentScrolled = (scrollView.contentOffset.y /
                                       scrollView.contentSize.height) * 100;
            if (percentScrolled >= kPagePercentageScrolled)
                return;
        }
        else
        {
            CGFloat percentScrolled = ((scrollView.contentOffset.y + scrollView.frame.size.height) /
                                       scrollView.contentSize.height) * 100;
            if (percentScrolled <= (100 - kPagePercentageScrolled))
                return;
        }
        
        [(id<MKPagingDelegate>)self scrollView:scrollView wantsPage:direction];
    }
    
    if (complete && [self respondsToSelector:@selector(scrollView:scrollingStopped:)])
        [(id<MKPagingDelegate>)self scrollView:scrollView scrollingStopped:YES];
}

- (void)pageScrollView:(UIScrollView *)scrollView direction:(MKPagingDirection)direction
{
     [self MKPaging_scrollViewDidScroll:scrollView direction:direction complete:YES];
}


@end
