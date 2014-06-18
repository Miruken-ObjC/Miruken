//
//  MKWhen.h
//  Miruken
//
//  Created by Craig Neuwirt on 6/18/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^MKWhenPredicate)(id object);

@interface MKWhen : NSObject

+ (MKWhenPredicate)kindOfClass:(Class)class;

+ (MKWhenPredicate)memberOfClass:(Class)class;

+ (MKWhenPredicate)conformsToProtocol:(Protocol *)protocol;

+ (MKWhenPredicate)error;

+ (MKWhenPredicate)errorInDomain:(NSString *)domain;

+ (MKWhenPredicate)errorInDomain:(NSString *)domain code:(NSInteger)code;

+ (MKWhenPredicate)exception;

+ (MKWhenPredicate)exceptionNamed:(NSString *)name;

+ (MKWhenPredicate)predicateFormat:(NSString *)format, ...;

+ (MKWhenPredicate)predicate:(NSPredicate *)predicate;

+ (MKWhenPredicate)criteria:(id)criteria;

+ (MKWhenPredicate)tryCriteria:(id)criteria;

@end

typedef MKWhen when;