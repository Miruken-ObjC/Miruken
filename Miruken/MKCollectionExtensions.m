//
//  CollectionUtil.m
//  Miruken
//
//  Created by Craig Neuwirt on 12/3/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCollectionExtensions.h"

#pragma mark - NSArray functional

@implementation NSArray (NSArray_Functional)

- (NSArray *)map:(id (^)(id obj))map
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self)
    {
        id mapped = map(obj);
        if (mapped)
            [array addObject:mapped];
    }
    return array;
}

- (NSArray *)mapMany:(NSArray * (^)(id obj))map
{
    NSMutableArray *array = [NSMutableArray new];
    for (id obj in self)
        [array addObjectsFromArray:map(obj)];
    return array;
}

- (NSArray *)select:(BOOL(^)(id obj))select
{
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in self)
    {
        if (select(obj))
            [array addObject:obj];
    }
    return array;
}

- (id)match:(BOOL(^)(id obj))match
{
    for (id obj in self)
    {
        if (match(obj))
            return obj;
    }
    return nil;
}

- (id)reduce:(id)initial reduce:(id (^)(id a, id b))reduce
{
    id result = initial;
    for (id obj in self)
        result = reduce(result, obj);
    return result;
}

@end

#pragma mark - NSSet functional

@implementation NSSet (NSSet_Functional)

- (NSSet *)map:(id (^)(id obj))map
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:self.count];
    for (id obj in self)
        [set addObject:map(obj)];
    return set;
}

- (NSSet *)mapMany:(NSArray * (^)(id obj))map
{
    NSMutableSet *set = [NSMutableSet new];
    for (id obj in self)
        [set addObjectsFromArray:map(obj)];
    return set;
}

- (NSSet *)select:(BOOL(^)(id obj))select
{
    NSMutableSet *set = [NSMutableSet set];
    for (id obj in self)
    {
        if(select(obj))
            [set addObject:obj];
    }
    return set;
}

- (id)match:(BOOL(^)(id obj))match
{
    for (id obj in self)
    {
        if(match(obj))
            return obj;
    }
    return nil;
}

@end

#pragma mark - NSMutableArray stack

@implementation NSMutableArray (Stack)

- (void)push:(id)item
{
    [self addObject:item];
}

- (id)pop
{
    id item = nil;
    if (self.count > 0)
    {
        item = [self lastObject];
        [self removeLastObject];
    }
    return item;
}

- (id)peek
{
    id item = nil;
    if (self.count > 0)
        item = [self lastObject];
    return item;
}

@end

#pragma mark - NSMutableArray queue

@implementation NSMutableArray (Queue)

- (void)enqueue: (id)item
{
    [self addObject:item];
}

- (id)dequeue
{
    id item = nil;
    if (self.count > 0)
    {
        item = self[0];
        [self removeObjectAtIndex:0];
    }
    return item;
}

- (id)peek
{
    id item = nil;
    if (self.count > 0)
        item = self[0];
    return item;
}

@end