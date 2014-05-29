//
//  MKTransitionOptions.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationOptions.h"

typedef NS_ENUM(NSUInteger, MKTransitionFadeStyle) {
    MKTransitionFadeStyleNone = 0,
    MKTransitionFadeStyleIn,
    MKTransitionFadeStyleOut,
    MKTransitionFadeStyleInOut,
};

@interface MKTransitionOptions : MKPresentationOptions

@property (assign, nonatomic) NSTimeInterval                            animationDuration;
@property (assign, nonatomic) MKTransitionFadeStyle                     fadeStyle;
@property (assign, nonatomic) CGFloat                                   perspective;
@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;

@end
