//
//  MKActiveCollectionViewCell.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/13/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKActiveCollectionViewCell.h"
#import "MKMixingIn.h"
#import "NSObject+Concurrency.h"

@implementation MKActiveCollectionViewCell

+ (void)initialize
{
    if (self == MKActiveCollectionViewCell.class)
        [MKDirtyObjectTrackingMixin mixInto:self];
}

- (void)objectBecameDirty:(NSObject *)object
{
    [[self onMainThread] refreshCollectionViewCellFromObject:object];
}

- (void)refreshCollectionViewCellFromObject:(NSObject *)object
{
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self untrackAllObjects];
}

@end
