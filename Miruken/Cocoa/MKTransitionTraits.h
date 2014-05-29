//
//  MKTransitionTraits.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MKTransitionTraits <NSObject>

@optional
- (instancetype)fadeIn;

- (instancetype)fadeOut;

- (instancetype)fadeInOut;

- (instancetype)duration:(NSTimeInterval)duration;

- (instancetype)perspective:(CGFloat)perspective;

@end
