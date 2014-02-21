//
//  MKDirtyMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDirtyMixin.h"
#import "MKMixin.h"
#import <objc/runtime.h>

static int             kDirtyMixinContext;
static NSString *const kIsDirtyProperty = @"isDirty";

@implementation MKDirtyMixin

+ (void)mixInto:(Class)class
{
    [class mixinFrom:self];
}

#pragma mark - DirtyChecking

- (BOOL)isDirty
{
    NSNumber *dirty = objc_getAssociatedObject(self, @selector(isDirty));
    return [dirty boolValue];
}

- (void)clearDirty
{
    [self setDirty:NO];
}

#pragma mark - DirtyChecking mixin 

- (void)setDirty:(BOOL)dirty
{
    NSNumber *dirtyBool = [NSNumber numberWithBool:dirty];
    objc_setAssociatedObject(self, @selector(isDirty), dirtyBool, OBJC_ASSOCIATION_RETAIN);
}

+ (id)swizzleDirty_alloc
{
    id object = [self swizzleDirty_alloc];

    [object addObserver:object forKeyPath:kIsDirtyProperty options:0 context:&kDirtyMixinContext];
    
    return object;
}

- (void)swizzleDirty_dealloc
{
    [self removeObserver:self forKeyPath:kIsDirtyProperty context:&kDirtyMixinContext];
    
    [self swizzleDirty_dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == &kDirtyMixinContext)
    {
        if ([keyPath isEqualToString:kIsDirtyProperty])
            [self setDirty:YES];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

+ (NSSet *)keyPathsForValuesAffectingIsDirty
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
            if ([propName isEqualToString:kIsDirtyProperty] == NO)
                [propSet addObject:propName];
        }
        
        free(propList);
        
        cls = class_getSuperclass(cls);
    }
    
    return propSet;
}

@end
