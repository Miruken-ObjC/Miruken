//
//  MKViewControllerWapperView.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/11/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKViewControllerWapperView : UIView

@property (assign, nonatomic) BOOL tightWrappingDisabled;

+ (instancetype)wrapperViewForView:(UIView *)view frame:(CGRect)frame;

+ (instancetype)existingWrapperViewForView:(UIView *)view;

@end
