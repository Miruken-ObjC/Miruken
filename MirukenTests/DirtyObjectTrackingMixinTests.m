//
//  DirtyObjectTrackingMixinTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/14/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKDirtyObjectTrackingMixin.h"
#import "MKDirtyMixin.h"

#pragma mark - Car model

@interface Car : MKDirtyChecking

@property (copy,   nonatomic) NSString *make;
@property (copy,   nonatomic) NSString *model;
@property (assign, nonatomic) float     mileage;

@end

@implementation Car
@end

@interface DirtyObjectTrackingMixinTests : XCTestCase <MKDirtyObjectTracking>

@end

@implementation DirtyObjectTrackingMixinTests
{
    Car *_dirtyCar;
}

+ (void)initialize
{
    if (self == DirtyObjectTrackingMixinTests.class)
        [MKDirtyObjectTrackingMixin mixInto:self];
}

- (void)setUp
{
    [super setUp];
    
    _dirtyCar = nil;
}

- (void)testNoTracking
{
    Car *car    = [Car new];
    car.make    = @"BMW";
    car.model   = @"325i";
    car.mileage = 1600000;
    
    XCTAssertNil(_dirtyCar, @"Car was tracked");
}

- (void)testCanTrackTarget
{
    Car *car = [Car new];
    [self trackObject:car];
    
    car.make    = @"BMW";
    car.model   = @"325i";
    car.mileage = 1600000;
    
    XCTAssertEqual(car, _dirtyCar, @"Car not tracked");
}

- (void)testCanUntrackTargetExplicitly
{
    Car *car = [Car new];
    [self trackObject:car];
    [self untrackObject:car];
    
    car.make    = @"BMW";
    car.model   = @"325i";
    car.mileage = 1600000;
    
    XCTAssertNil(_dirtyCar, @"Car was tracked");
}

- (void)testCanUntrackTargetImplicitly
{
    Car *car = [Car new];
    MKDirtyUntrackObject untrack = [self trackObject:car];
    untrack();
    
    car.make    = @"BMW";
    car.model   = @"325i";
    car.mileage = 1600000;
    
    XCTAssertNil(_dirtyCar, @"Car was tracked");
}

#pragma mark - DirtyObjectTracking

- (void)objectBecameDirty:(Car *)car
{
    _dirtyCar = car;
}

@end
