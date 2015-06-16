//
//  MKWeakCell.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKWeakCell.h"

@implementation MKWeakCell
{
    id __weak    _object;
    MKWeakCell    *_next;
}

+ (MKWeakCell *)cons:(id)object
{
    MKWeakCell *cell = [MKWeakCell new];
    cell->_object  = object;
    return cell;
}

+ (MKWeakCell *)cons:(id)object next:(MKWeakCell *)next
{
    MKWeakCell *cell = [MKWeakCell new];
    cell->_object  = object;
    cell->_next    = next;
    return cell;
}

- (MKWeakCell *)add:(id)object
{
    MKWeakCell *cell = [MKWeakCell new];
    cell->_object  = object;
    cell->_next    = self;
    return cell;
}

- (MKWeakCell *)remove:(id)object
{
    MKWeakCell *cell;
    __unsafe_unretained MKWeakCell *current = self;
    do
    {
        if (current->_object == object || [current->_object isEqual:object])
        {
            if (cell == nil)
                return current->_next;
            cell->_next = current->_next;
            return cell;
        }
        if (cell == nil)
            cell = [MKWeakCell cons:current->_object];
        else
            cell = [MKWeakCell cons:current->_object next:cell];
        current = current->_next;
    }
    while (current);
    return cell;
}

- (NSArray *)array
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (id object in self)
        [array addObject:object];
    
    return [array copy];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
{
    // plan of action: pretty much the same as before,
    // with extra[0] pointing to the next node to use
    // we just iterate over multiple nodes at once
    if (state->state == 0)
    {
        state->mutationsPtr = (__bridge void *)self;
        state->extra[0]     = (long)self;
        state->state        = 1;
    }
    
    // pull the node out of extra[0]
    MKWeakCell __unsafe_unretained *cell = (__bridge MKWeakCell *)((void *)state->extra[0]);
    
    // keep track of how many objects we iterated over so we can return
    // that value
    NSUInteger objCount = 0;
    
    // we'll be putting objects in buffer, so point itemsPtr to it
    state->itemsPtr = buffer;
    
    // loop through until either we fill up buffer or run out of nodes
    while (cell && objCount < len)
    {
        if (cell->_object == nil)
        {
            cell = cell->_next;
            continue;
        }
            
        // fill current buffer location and move to the next
        *buffer++ = cell->_object;
        
        // move to next node
        cell = cell->_next;
        
        // and keep our count
        objCount++;
    }
    
    // update extra[0]
    state->extra[0] = (long)cell;
    
    return objCount;
}

@end
