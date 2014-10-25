//
//  UIImage+Helpers.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "UIImage+Helpers.h"

@implementation UIImage (UIImage_Helpers)

- (UIImage *)scaledToWidth:(CGFloat)width
{
    CGFloat oldWidth = self.size.width;
    CGFloat scaleFactor = width / oldWidth;
    
    CGFloat newHeight = self.size.height * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaledToHeight:(CGFloat)height
{
    CGFloat oldHeight = self.size.height;
    CGFloat scaleFactor = height / oldHeight;
    
    CGFloat newWidth = self.size.width * scaleFactor;
    CGFloat newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleToMaxSize:(CGSize)maxSize
{
    if ((self.size.height < maxSize.height) && (self.size.width < maxSize.width))
        return [self copy];
    
    // landscape
    if (self.size.width > self.size.height)
        return [self scaledToWidth:maxSize.width];
    
    //self.size.height >= self.size.width portrait or square
    return [self scaledToHeight:maxSize.height];
}

+ (UIImage *)resizeableImageWithColor:(UIColor *)color
{
    CGRect       rect    = CGRectMake(0.0f, 0.0f, 3.0f, 3.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage     *image   = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)];
}

@end
