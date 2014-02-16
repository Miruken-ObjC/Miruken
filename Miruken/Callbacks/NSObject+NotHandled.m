//
//  NSObject+NotHandled.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/22/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "NSObject+NotHandled.h"
#import "MKHandleMethod.h"

@implementation NSObject (NSObject_NotHandled)

- (id)notHandled
{
    [[MKHandleMethod current] notHandled];
    return nil;
}

- (BOOL)boolNotHandled
{
    [[MKHandleMethod current] notHandled];
    return NO;
}

- (char)charNotHandled
{
    [[MKHandleMethod current] notHandled];
    return '\000';
}

- (double)doubleNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0.0;
}

- (float)floatNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0.0;
}

- (int)intNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (NSInteger)integerNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (long long)longLongNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (long)longNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (short)shortNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (unsigned char)unsignedCharNotHandled
{
    [[MKHandleMethod current] notHandled];
    return '\000';
}

- (NSUInteger)unsignedIntegerNotHandled
{
    [[MKHandleMethod current] notHandled];
    return  0;
}

- (unsigned int)unsignedIntNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (unsigned long long)unsignedLongLongNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (unsigned long)unsignedLongNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

- (unsigned short)unsignedShortNotHandled
{
    [[MKHandleMethod current] notHandled];
    return 0;
}

@end
