//
//  UIStoryboard+Naming.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/11/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "UIStoryboard+Naming.h"

@implementation UIStoryboard (UIStoryboard_Naming)

+ (UIStoryboard *)storyboardWithBaseName:(NSString *)baseName bundleForClass:(Class)class
{
    NSBundle *bundle = class ? [NSBundle bundleForClass:class] : nil;
    return [self storyboardWithBaseName:baseName bundle:bundle];
}

+ (UIStoryboard *)storyboardWithBaseName:(NSString *)baseName bundle:(NSBundle *)bundle
{
    NSString *fullName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
                       ? [baseName stringByAppendingString:@"_iPad"]
                       : [baseName stringByAppendingString:@"_iPhone"];
    
    @try {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:fullName bundle:bundle];
        if (storyBoard)
            return storyBoard;
    }
    @catch (NSException *exception) {
        return [UIStoryboard storyboardWithName:baseName bundle:bundle];
    }
}

@end
