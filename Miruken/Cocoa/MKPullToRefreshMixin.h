//
//  MKPullToRefreshMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MKPromise.h"

/**
   Protocol adopted by targets interested in pull-to-refresh support
 */

typedef NS_ENUM(NSUInteger, MKPullToRefreshMode) {
    MKPullToRefreshModePull = 0,
    MKPullToRefreshModeRelease,
    MKPullToRefreshModeRefreshing
};

@protocol MKPullToRefresh

@property (assign, nonatomic) MKPullToRefreshMode mode;

@optional
@property (assign, nonatomic) CGFloat pullPercent;

@end

@protocol MKPullToRefreshDelegate

- (MKPromise)performRefresh;

@optional
- (CGFloat)minTriggerRefreshOffset;

- (UIView<MKPullToRefresh> *)pullToRefreshViewInScrollView:(UIScrollView *)scrollView;

- (BOOL)scrollToTopAfterRefresh;

@end

/**
   This class is an opaque mix-in that adds pull-to-refresh support.
   It can only be mixed into classes conforming to UIScrollViewDelegate protocol.
   e.g. [MKPullToRefreshMixin mixInto:MyScrollingController.class]
 */

@interface MKPullToRefreshMixin : NSObject <UIScrollViewDelegate>

@end

