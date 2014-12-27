//
//  MKDirtyMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDirtyMixin.h"
#import "MKMixingIn.h"
#import <objc/runtime.h>

static NSString *const kIsDirtyProperty       = @"isDirty";
static NSString *const kInternalDirtyProperty = @"Dirty_isDirty";
static int             kDirtyMixinContext;

@implementation MKDirtyChecking

+ (void)initialize
{
    if (self == MKDirtyChecking.class)
        [MKDirtyMixin mixInto:self];
}

@end

@implementation MKDirtyMixin

#pragma mark - MKDirtyChecking

- (BOOL)isDirty
{
    return [self MKDirty_isDirty];
}

- (void)clearDirty
{
    [self MKDirty_setDirty:NO notify:NO];
}

- (void)batchUpdates:(void (^)(void))updates
{
    if (updates)
    {
        BOOL suppress = [self MKDirty_suppress];
        @try {
            [self setMKDirty_suppress:YES];
            [self clearDirty];
            updates();
            if ([self MKDirty_isDirty])
            {
                // willChangeValueForKey must be called first to generate notification
                objc_setAssociatedObject(self, @selector(isDirty), nil, OBJC_ASSOCIATION_RETAIN);
                [self willChangeValueForKey:kIsDirtyProperty];
                objc_setAssociatedObject(self, @selector(isDirty), @YES, OBJC_ASSOCIATION_RETAIN);
                [self didChangeValueForKey:kIsDirtyProperty];
            }

        }
        @finally {
            [self setMKDirty_suppress:suppress];
        }
    }
}

#pragma mark - MKDirtyChecking mixin

- (BOOL)MKDirty_isDirty
{
    NSNumber *dirty = objc_getAssociatedObject(self, @selector(isDirty));
    return [dirty boolValue];
}

- (void)MKDirty_setDirty:(BOOL)dirty notify:(BOOL)notify
{
    BOOL changed = ([self isDirty] != dirty);
    notify       = ((notify || changed) && ([self MKDirty_suppress] == NO));
    
    if (notify)
        [self willChangeValueForKey:kIsDirtyProperty];
    
    if (changed)
    {
        NSNumber *dirtyBool = dirty ? @YES : nil;
        objc_setAssociatedObject(self, @selector(isDirty), dirtyBool, OBJC_ASSOCIATION_RETAIN);
    }
    
    if (notify)
        [self didChangeValueForKey:kIsDirtyProperty];
}

- (BOOL)MKDirty_suppress
{
    NSNumber *suppress = objc_getAssociatedObject(self, @selector(MKDirty_suppress));
    return [suppress boolValue];
}

- (void)setMKDirty_suppress:(BOOL)suppress
{
    NSNumber *suppressBool = suppress ? @YES : nil;
    objc_setAssociatedObject(self, @selector(MKDirty_suppress), suppressBool, OBJC_ASSOCIATION_RETAIN);
}

/**
 * alloc calls allocWithZone:nil
 */
+ (id)swizzleDirty_allocWithZone:(NSZone *)zone
{
    id object = [self swizzleDirty_allocWithZone:zone];
    [object addObserver:object forKeyPath:kInternalDirtyProperty options:0 context:&kDirtyMixinContext];
    return object;
}

- (void)swizzleDirty_dealloc
{
    [self removeObserver:self forKeyPath:kInternalDirtyProperty context:&kDirtyMixinContext];
    [self swizzleDirty_dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == &kDirtyMixinContext)
    {
        if ([keyPath isEqualToString:kInternalDirtyProperty])
            [self MKDirty_setDirty:YES notify:YES];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey
{
    return [theKey isEqualToString:kIsDirtyProperty]
         ? NO
         : [super automaticallyNotifiesObserversForKey:theKey];
}

+ (NSSet *)keyPathsForValuesAffectingDirty_isDirty
{
    Class         cls     = self;
    NSMutableSet *propSet = [NSMutableSet set];
    
    while (cls && cls != NSObject.class)
    {
        unsigned int  numProps;
        objc_property_t *propList = class_copyPropertyList(cls, &numProps);
        
        for (unsigned int i = 0; i < numProps; ++i)
        {
            NSString *propName = [NSString stringWithUTF8String:property_getName(propList[i])];
            if ([propName isEqualToString:kInternalDirtyProperty] == NO &&
                [propName isEqualToString:kIsDirtyProperty] == NO)
                [propSet addObject:propName];
        }
        
        free(propList);
        
        cls = class_getSuperclass(cls);
    }
    
    return propSet;
}

@end
