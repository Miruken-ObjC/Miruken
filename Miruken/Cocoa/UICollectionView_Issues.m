//
//  UICollectionView_Issues.m
//  Miruken
//
//  Created by Craig Neuwirt on 12/5/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "UICollectionView_Issues.h"
#import "MKMixin.h"

@interface UICollectionView_IssuesMixin : NSObject
@end

/**
  UICollectionView has a major bug that causes large cells (> 2x height) to dissappear.
  When the scrolling offset of the UICollectionView exceeds 
     cell.frame.origin.y + displayHeightOfHardware the cell is hidden.
  When further cells come into view, the cell is then redisplayed.
  */

@implementation UICollectionView_IssuesMixin

- (CGRect)swizzleCollectionViewIssues__visibleBounds
{
    CGRect rect = [self swizzleCollectionViewIssues__visibleBounds];
    
    UICollectionView *collectionView = (UICollectionView *)self;
    NSArray          *layouts        = [collectionView.collectionViewLayout
                                        layoutAttributesForElementsInRect:rect];

    for (UICollectionViewLayoutAttributes *layout in layouts)
    {
        if (layout.representedElementCategory == UICollectionElementCategoryCell)
            rect.size.height = MAX(rect.size.height, CGRectGetHeight(layout.frame));
    }
    
    return rect;
}

@end

@implementation UICollectionView (UICollectionView_Issues)

+ (void)fixLargeCellIssue
{
    [UICollectionView mixinFrom:UICollectionView_IssuesMixin.class];
}

@end