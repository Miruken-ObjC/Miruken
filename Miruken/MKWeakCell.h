//
//  MKWeakCell.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  A MKWeakCell represents a weak linked list.
  */

@interface MKWeakCell : NSObject <NSFastEnumeration>

+ (MKWeakCell *)cons:(id)object;

+ (MKWeakCell *)cons:(id)object next:(MKWeakCell *)next;

- (MKWeakCell *)add:(id)object;

- (MKWeakCell *)remove:(id)object;

@end
