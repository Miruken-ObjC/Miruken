//
//  MKActiveCollectionViewCell.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/13/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDirtyObjectTrackingMixin.h"

@interface MKActiveCollectionViewCell : UICollectionViewCell <MKDirtyObjectTracking>

- (void)refreshCollectionViewCellFromObject:(NSObject *)object;

@end
