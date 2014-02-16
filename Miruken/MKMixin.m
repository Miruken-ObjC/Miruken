//
//  MKMixin.m
//  ObjectiveMixin
//
//  Created by Vladimir Mitrovic on 24/02/2011.
//  Copyright 2011 Vladimir Mitrovic. All rights reserved.
//

#import "MKMixin.h"
#import <objc/runtime.h>


@implementation MKMixin

+ (void)mixinFrom:(id)source into:(id)destination force:(BOOL)force
{
	unsigned int methodCount = 0;
	Method* methods = class_copyMethodList(source, &methodCount);
    
    // Swizzle methods first so we don't accidently swizzle methods that
    // have been added by this mixin.
    
    [self swizzleMethods:methods from:source methodCount:methodCount into:destination force:force];
    
	for (int i = 0; i < methodCount; i++) {
		Method m = methods[i];
		
		SEL name = method_getName(m);
        NSString *selName = NSStringFromSelector(name);
        
        if ([self isSizzleMethod:selName] || [selName hasPrefix:@"mixInto"])
            continue;
        
		IMP imp = method_getImplementation(m);
		const char* types = method_getTypeEncoding(m);

        if (force) {
			class_replaceMethod(destination, name, imp, types);
		} else {
			// Will fail if method already exists
			class_addMethod(destination, name, imp, types);
		}
	}
	
	if (methods)
		free(methods);
}

+ (void)swizzleMethods:(Method *)methods from:(id)source methodCount:(unsigned int)methodCount
                  into:(id)destination force:(BOOL)force
{
	for (int i = 0; i < methodCount; i++) {
		Method m = methods[i];
		
		SEL name = method_getName(m);
		IMP imp = method_getImplementation(m);
		const char* types = method_getTypeEncoding(m);
		
        NSString *selName = NSStringFromSelector(name);
        if ([self isSizzleMethod:selName]) {
            if ([destination respondsToSelector:name])
            {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:
                                                       @"Mixin %@ requires swizzling, but the "
                                                       @"%@ method is already used by another mixin.",
                                                       source, selName]
                                             userInfo:nil];
            }
            
            NSRange underscore = [selName rangeOfString:@"_"];
            SEL originalName = NSSelectorFromString([selName substringFromIndex:underscore.location + 1]);
            Method original = class_getInstanceMethod(destination, originalName);
            if (original) {
                IMP originalImp = method_getImplementation(original);
                class_replaceMethod(destination, originalName, imp, types);
                if (force) {
                    class_replaceMethod(destination, name, originalImp, types);
                } else {
                    class_addMethod(destination, name, originalImp, types);
                }
            }
        }
    }
}

+ (void)from:(Class)sourceClass into:(Class)destinationClass followInheritance:(BOOL)followInheritance
       force:(BOOL)force
{
	if (followInheritance) {
		// Mixin from all ancestor classes recursively, up to the common ancestor
		Class sourceParent = class_getSuperclass(sourceClass);
		if (sourceParent != nil) {
			// Find a common ancestor for sourceClass and destinationClass
			Class destinationParent = destinationClass;
			while ((destinationParent = class_getSuperclass(destinationParent)) != nil && destinationParent != sourceParent);
			
			// Only mixin from sourceParent if it's not an ancestor of destinationClass
			if (destinationParent == nil) {
				[self from:sourceParent into:destinationClass followInheritance:YES force:force];
			}
		}
	}
	
	// Mixin instance methods
	[self mixinFrom:sourceClass into:destinationClass force:force];
	
	// Mixin class methods
	[self mixinFrom:object_getClass(sourceClass) into:object_getClass(destinationClass) force:force];
}

+ (void)from:(Class)sourceClass into:(Class)destinationClass
{
	[self from:sourceClass into:destinationClass followInheritance:NO force:NO];
}

+ (BOOL)isSizzleMethod:(NSString *)method
{
    return ([method hasPrefix:@"swizzle"] && [method rangeOfString:@"_"].location != NSNotFound);
}

@end


@implementation NSObject (MKMixin)

- (void)mixinFrom:(Class)sourceClass
{
	[MKMixin from:sourceClass into:[self class]];
}

- (void)mixinFrom:(Class)sourceClass followInheritance:(BOOL)followInheritance force:(BOOL)force
{
	[MKMixin from:sourceClass into:[self class] followInheritance:followInheritance force:force];
}

+ (void)mixinFrom:(Class)sourceClass
{
	[MKMixin from:sourceClass into:self];
}

+ (void)mixinFrom:(Class)sourceClass followInheritance:(BOOL)followInheritance force:(BOOL)force
{
	[MKMixin from:sourceClass into:self followInheritance:followInheritance force:force];
}

+ (Class)classWithSuperclass:(Class)superClass
{
    Protocol *protocol = nil;
    
    NSString *myClassName = NSStringFromClass(self);
    if([myClassName hasSuffix:@"Mixin"]) {
        protocol = NSProtocolFromString([myClassName substringToIndex:myClassName.length - 5]);
    }
    
    Class fromClass = self;
    NSString *dynamicClassName = [NSString stringWithFormat:@"%@_WithSuperclass_%@", NSStringFromClass(fromClass), NSStringFromClass(superClass)];
    if(protocol) {
        dynamicClassName = [NSString stringWithFormat:@"%@_ConformingToProtocol_%@", dynamicClassName, NSStringFromProtocol(protocol)];
    }
    
    Class dynamicClass = NSClassFromString(dynamicClassName);
    
    if (!dynamicClass) {
        dynamicClass = objc_allocateClassPair(fromClass, [dynamicClassName UTF8String], 0);
        
        [MKMixin from:fromClass into:dynamicClass];
        
        if (protocol)
            class_addProtocol(dynamicClass, protocol);
        
        objc_registerClassPair(dynamicClass);
    }
    
    return dynamicClass;
}


+ (id)allocWithSuperclass:(Class)superClass
{
    return [[self classWithSuperclass:superClass] alloc];
}

@end