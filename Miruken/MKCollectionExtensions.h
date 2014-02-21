//
//  CollectionUtil.h
//  Miruken
//
//  Created by Craig Neuwirt on 12/3/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Basic functional support for collections.
  */

@interface NSArray (NSArray_Functional)

- (NSArray *)map:(id (^)(id obj))map;

- (NSArray *)mapMany:(NSArray * (^)(id obj))map;

- (NSArray *)select:(BOOL(^)(id obj))select;

- (id)match:(BOOL (^)(id obj))match;

- (id)reduce:(id)initial reduce:(id (^)(id a, id b))reduce;

@end

@interface NSSet (NSSet_Functional)

- (NSSet *)map:(id (^)(id obj))map;

- (NSSet *)mapMany:(NSArray * (^)(id obj))map;

- (NSSet *)select:(BOOL(^)(id obj))select;

- (id)match:(BOOL(^)(id obj))match;

@end

/**
 Basic stack support for arrays.
 */

@interface NSMutableArray (Stack)

- (void)push:(id)item;
- (id)pop;
- (id)peek;

@end

/**
 Basic queue support for arrays.
 */

@interface NSMutableArray (Queue)

- (void)enqueue: (id)item;
- (id)dequeue;
- (id)peek;

@end