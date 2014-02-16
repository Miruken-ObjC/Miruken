//
//  NSObject+NotHandled.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/22/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  NSObject category for indicating a callback was not handled.
 */

@interface NSObject (NSObject_NotHandled)

- (id)notHandled;

- (BOOL)boolNotHandled;

- (char)charNotHandled;

- (double)doubleNotHandled;

- (float)floatNotHandled;

- (int)intNotHandled;

- (NSInteger)integerNotHandled;

- (long long)longLongNotHandled;

- (long)longNotHandled;

- (short)shortNotHandled;

- (unsigned char)unsignedCharNotHandled;

- (NSUInteger)unsignedIntegerNotHandled;

- (unsigned int)unsignedIntNotHandled;

- (unsigned long long)unsignedLongLongNotHandled;

- (unsigned long)unsignedLongNotHandled;

- (unsigned short)unsignedShortNotHandled;

@end
