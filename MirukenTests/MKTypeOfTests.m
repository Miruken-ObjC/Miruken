//
//  MKTypeOfTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 8/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKTypeOf.h"

@interface MKTypeOfTests : XCTestCase

@end

@implementation MKTypeOfTests

- (void)testCanIdentifyNil
{
    XCTAssertEqual(MKIdTypeNil, [MKTypeOf id:nil], @"Should be IdTypeNil");
}

- (void)testCanIdentifyObject
{
    XCTAssertEqual(MKIdTypeObject, [MKTypeOf id:@"Hello"], @"Should be IdTypeObject");
}

- (void)testCanIdentifyClass
{
    XCTAssertEqual(MKIdTypeClass, [MKTypeOf id:NSString.class], @"Should be IdTypeClass");
}

- (void)testCanIdentifyProtocol
{
    XCTAssertEqual(MKIdTypeProtocol, [MKTypeOf id:@protocol(NSCopying)], @"Should be IdTypeProtocol");
}

- (void)testCanIdentifyBlock
{
    void (^b1)() = ^() {};
    XCTAssertEqual(MKIdTypeBlock, [MKTypeOf id:b1], @"Should be IdTypeBlock");
    
    BOOL (^b2)(id obj) = ^(id o) { return YES; };
    XCTAssertEqual(MKIdTypeBlock, [MKTypeOf id:b2], @"Should be IdTypeBlock");
    
    id (^b3)(id obj) = ^(id o) { return o; };
    XCTAssertEqual(MKIdTypeBlock, [MKTypeOf id:b3], @"Should be IdTypeBlock");
}

@end
