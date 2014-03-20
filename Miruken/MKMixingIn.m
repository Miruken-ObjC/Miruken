//
//  MKMixingIn.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKMixingIn.h"
#import "MKMixin.h"
#import <objc/runtime.h>

@implementation NSObject (NSObject_MKMixingIn)

+ (void)mixInto:(Class)targetClass
{
    NSMutableArray *mixIns = objc_getAssociatedObject(targetClass, @selector(classesMixedIn));
    if (mixIns == nil)
    {
        mixIns = [NSMutableArray new];
        objc_setAssociatedObject(targetClass, @selector(classesMixedIn), mixIns, OBJC_ASSOCIATION_RETAIN);
    }
    else if ([mixIns containsObject:self])
        return;
    
    if ([self respondsToSelector:@selector(verifyCanMixIntoClass:)])
        [self verifyCanMixIntoClass:targetClass];
    
    [mixIns addObject:targetClass];
    [targetClass mixinFrom:self];
}

+ (NSArray *)classesMixedIn
{
    NSMutableArray *mixIns = objc_getAssociatedObject(self, @selector(classesMixedIn));
    return mixIns ? [mixIns copy] : @[];
}

@end
