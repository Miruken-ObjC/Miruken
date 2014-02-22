//
//  MKPagingMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MKPagingDirection) {
    MKPagingDirectionUp = 0,
    MKPagingDirectionDown
};

/**
  Protocol adopted by targets interested in paging support
  */

@protocol MKPagingDelegate

@optional
- (void)scrollView:(UIScrollView *)scrollView wantsPage:(MKPagingDirection)pagingDirection;

- (void)scrollView:(UIScrollView *)scrollView didScroll:(MKPagingDirection)pagingDirection;

- (void)scrollView:(UIScrollView *)scrollView scrollingStopped:(BOOL)decelerated;

- (void)pageScrollView:(UIScrollView *)scrollView direction:(MKPagingDirection)direction;

@end

/**
  This class is an opaque mix-in that adds paging support.
  It can only be mixed into classes conforming to UIScrollViewDelegate protocol.
    e.g. [MKPagingMixin mixInto:MyScrollingController.class]
 */

@interface MKPagingMixin : NSObject <UIScrollViewDelegate>

+ (void)mixInto:(Class)class;

@end
