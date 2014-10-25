//
//  UIImage+Helpers.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Helpers)

- (UIImage *)scaledToWidth:(CGFloat)width;

- (UIImage *)scaledToHeight:(CGFloat)height;

- (UIImage *)scaleToMaxSize:(CGSize)maxSize;

+ (UIImage *)resizeableImageWithColor:(UIColor *)color;

@end
