//
//  MKPageFoldTransition.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Colin Eberhardt on 09/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "MKAnimatedTransition.h"

@interface MKPageFoldTransition : MKAnimatedTransition

@property (assign, nonatomic) NSUInteger folds;
@property (assign, nonatomic) CGFloat    perspective;

+ (instancetype)folds:(NSUInteger)folds;

@end
