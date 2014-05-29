//
//  MKPresentationPolicy.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationOptions.h"

@interface MKPresentationPolicy : MKPresentationOptions

@property (readonly, copy, nonatomic) NSArray *options;

- (id)initWithOptions:(NSArray *)options;

- (id<MKPresentationOptions>)optionsWithClass:(Class)optionsClass;

- (void)addOrMergeOptions:(id<MKPresentationOptions>)options;

- (void)removeOptionsWithClass:(Class)optionsClass;

@end
