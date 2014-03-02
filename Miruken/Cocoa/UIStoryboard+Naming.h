//
//  UIStoryboard+Naming.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/11/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (UIStoryboard_Naming)

+ (UIStoryboard *)storyboardWithBaseName:(NSString *)baseName bundleForClass:(Class)class;

+ (UIStoryboard *)storyboardWithBaseName:(NSString *)baseName bundle:(NSBundle *)bundle;

@end
