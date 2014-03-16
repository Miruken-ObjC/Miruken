//
//  MKDirtyMixinTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKDirtyMixin.h"

#pragma mark - Person model

@interface Person : MKDirtyChecking

@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;

@end

@implementation Person
@end

#pragma mark - Doctor model

@interface Doctor : Person

@property (copy, nonatomic) NSString *speciality;

@end

@implementation Doctor

@end

@interface MKDirtyMixinTests : XCTestCase

@end

@implementation MKDirtyMixinTests
{
    BOOL _isDirty;
}

- (void)testCanDetectWhenDeclaredPropertiesChange
{
    Person *person   = [Person new];
    XCTAssertFalse(person.isDirty, @"Person should not be dirty");
    
    person.firstName = @"John";
    XCTAssertTrue(person.isDirty, @"Person should be dirty");
}

- (void)testCanClearDirtyIndicator
{
    Person *person   = [Person new];
    person.firstName = @"John";
    XCTAssertTrue(person.isDirty, @"Person should be dirty");
    
    [person clearDirty];
    XCTAssertFalse(person.isDirty, @"Person should not be dirty");
}

- (void)testCanDetectWhenDelcaredPropertiesOfInheritedClassChange
{
    Doctor *doctor = [Doctor new];
    XCTAssertFalse(doctor.isDirty, @"Doctor should not be dirty");
    
    doctor.speciality = @"spine";
    XCTAssertTrue(doctor.isDirty, @"Doctor should be dirty");
}

- (void)testCanDetectWhenInheritedPropertiesChange
{
    Doctor *doctor = [Doctor new];
    XCTAssertFalse(doctor.isDirty, @"Doctor should not be dirty");
    
    doctor.firstName = @"Daniel";
    XCTAssertTrue(doctor.isDirty, @"Doctor should be dirty");
}

- (void)testCanObserveDirtyChanges
{
    _isDirty = NO;
    Doctor *doctor = [Doctor new];
    [doctor addObserver:self forKeyPath:@"isDirty" options:0 context:(__bridge void *)self];
    doctor.speciality = @"knees";
    [doctor removeObserver:self forKeyPath:@"isDirty" context:(__bridge void *)self];
    XCTAssertTrue(_isDirty, @"KVO failed for isDirty");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)self)
        _isDirty = YES;
}

@end
