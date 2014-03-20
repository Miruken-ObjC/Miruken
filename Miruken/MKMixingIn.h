//
//  MKMixingIn.h
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Protocol adopted by targets using mix-ins.
 */

@protocol MKMixingIn

+ (void)mixInto:(Class)targetClass;

+ (NSArray *)classesMixedIn;

@end

@protocol MKMixInConstraints

@optional
+ (void)verifyCanMixIntoClass:(Class)targetClass;

@end

@interface NSObject (NSObject_MKMixingIn) <MKMixingIn, MKMixInConstraints>

@end
