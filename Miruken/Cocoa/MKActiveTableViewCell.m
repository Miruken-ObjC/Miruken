//
//  MKActiveTableViewCell.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/12/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKActiveTableViewCell.h"
#import "MKMixingIn.h"
#import "NSObject+Concurrency.h"

@implementation MKActiveTableViewCell

+ (void)initialize
{
    if (self == MKActiveTableViewCell.class)
        [MKDirtyObjectTrackingMixin mixInto:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self configureSelectedState:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self configureSelectedState:highlighted];
}

- (void)configureSelectedState:(BOOL)selected
{
}

- (void)objectBecameDirty:(NSObject *)object
{
    [[self onMainThread] refreshTableViewCellFromObject:object];
}

- (void)refreshTableViewCellFromObject:(NSObject *)object
{
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self untrackAllObjects];
}

@end
