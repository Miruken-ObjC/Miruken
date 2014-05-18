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
    return [self Dirty_isDirty];
}

- (void)clearDirty
{
    [self Dirty_setDirty:NO notify:NO];
}

- (void)batchUpdates:(void (^)(void))updates
{
    if (updates)
    {
        BOOL suppress = [self Dirty_suppress];
        @try {
            [self setDirty_suppress:YES];
            [self clearDirty];
            updates();
            if ([self Dirty_isDirty])
                [self didChangeValueForKey:kIsDirtyProperty];
        }
        @finally {
            [self setDirty_suppress:suppress];
        }
    }
}

#pragma mark - MKDirtyChecking mixin

- (BOOL)Dirty_isDirty
{
    NSNumber *dirty = objc_getAssociatedObject(self, @selector(isDirty));
    return [dirty boolValue];
}

- (void)Dirty_setDirty:(BOOL)dirty notify:(BOOL)notify
{
    BOOL changed = ([self isDirty] != dirty);
    notify       = ((notify || changed) && ([self Dirty_suppress] == NO));
    
    if (notify)
        [self willChangeValueForKey:kIsDirtyProperty];
    
    if (changed)
    {
        NSNumber *dirtyBool = dirty ? [NSNumber numberWithBool:YES] : nil;
        objc_setAssociatedObject(self, @selector(isDirty), dirtyBool, OBJC_ASSOCIATION_RETAIN);
    }
    
    if (notify)
        [self didChangeValueForKey:kIsDirtyProperty];
}

- (BOOL)Dirty_suppress
{
    NSNumber *suppress = objc_getAssociatedObject(self, @selector(Dirty_suppress));
    return [suppress boolValue];
}

- (void)setDirty_suppress:(BOOL)suppress
{
    NSNumber *suppressBool = suppress ? [NSNumber numberWithBool:YES] : nil;
    objc_setAssociatedObject(self, @selector(Dirty_suppress), suppressBool, OBJC_ASSOCIATION_RETAIN);
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
            [self Dirty_setDirty:YES notify:YES];
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
