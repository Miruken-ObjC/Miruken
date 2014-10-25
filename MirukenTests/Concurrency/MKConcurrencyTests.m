//
//  MKConcurrencyTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MirukenConcurrency.h"

@interface Calculator : NSObject

- (NSNumber *)isOnMainThread;

- (int)addSimple:(int)operand to:(int)to;

- (NSNumber *)add:(int)operand to:(int)to;

- (NSNumber *)divide:(double)operand by:(double)by;

- (void)clear;

@end

@implementation Calculator

- (void)clear
{
}

- (NSNumber *)isOnMainThread
{
    return @([NSThread isMainThread]);
}

- (int)addSimple:(int)operand to:(int)to
{
    return operand + to;
}

- (NSNumber *)add:(int)operand to:(int)to
{
    [NSThread sleepForTimeInterval:1];
    return @(operand + to);
}

- (NSNumber *)divide:(double)operand by:(double)by
{
    if (by == 0)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"cannot divide by 0"
                                     userInfo:nil];
    
    return @(operand / by);
}

@end

#pragma mark - TestAsyncDelegate

@interface TestAsyncDelegate : MKAsyncDelegate

@property (strong, nonatomic) id<MKAsyncResult> asyncResult;

@end

@implementation TestAsyncDelegate

- (void)completeResult:(id<MKAsyncResult>)asyncResult
{
    _asyncResult = asyncResult;
    [super completeResult:asyncResult];
}

@end
@interface MKConcurrencyTests : XCTestCase

@end

@implementation MKConcurrencyTests

- (void)testCanPerformInvocationsOnNewThreadWithNoResult
{
    Calculator *calculator  = [[Calculator new] inNewThread];
    [calculator clear];
}

- (void)testCanPerformInvocationsOnQueueWithNoResult
{
    NSOperationQueue *queue = [NSOperationQueue new];
    Calculator *calculator  = [[Calculator new] onQueue:queue];
    [calculator clear];
}

- (void)testCanDispatchInvocationsOnQueueWithNoResult
{
    Calculator *calculator = [[Calculator new] dispatchGlobal];
    [calculator clear];
}

- (void)testCanPerformInvocationsUsingCustomStrategyWithNoResult
{
    TestAsyncDelegate *testStrategy = [TestAsyncDelegate new];
    Calculator        *calculator   = [[Calculator new] concurrent:testStrategy];
    [calculator clear];
    XCTAssertNotNil(testStrategy.asyncResult, @"AsyncResult is nil");
}

- (void)testCanPerformInvocationsOnNewThread
{
    Calculator *calculator = [Calculator new];
    XCTAssertTrue([[calculator isOnMainThread] boolValue], @"Calculation should be on main thread");
    XCTAssertFalse([[[calculator inNewThread] isOnMainThread] boolValue], @"Calculation should not be on main thread");
}

- (void)testWillReturnProxyValueForObjects
{
    Calculator *calculator = [[Calculator new] inNewThread];
    NSNumber   *sum        = [calculator add:5 to:6];
    XCTAssertEqual(11, [sum intValue], @"Sum should be 11");
}

- (void)testCanPerformInvocationsOnOperationQueue
{
    NSOperationQueue *queue = [NSOperationQueue new];
    Calculator *calculator  = [[Calculator new] onQueue:queue];
    NSNumber   *sum         = [calculator add:5 to:6];
    XCTAssertEqual(11, [sum intValue], @"Sum should be 11");
}

- (void)testCanDispatchInvocationsOnQueue
{
    Calculator *calculator  = [[Calculator new] dispatchGlobal];
    NSNumber   *sum         = [calculator add:5 to:6];
    XCTAssertEqual(11, [sum intValue], @"Sum should be 11");
}

- (void)testCanPerformInvocationsOnImplicitQueue
{
    Calculator *calculator  = [[Calculator new] queued];
    NSNumber   *sum         = [calculator add:5 to:6];
    XCTAssertEqual(11, [sum intValue], @"Sum should be 11");
}

- (void)testWillPropogateExceptionsFromNewThread
{
    Calculator *calculator    = [[Calculator new] inNewThread];
    XCTAssertThrows([[calculator divide:10 by:0] doubleValue], @"Expected division by 0 exception");
}

- (void)testWillPropogateExceptionsFromOperationQueue
{
    NSOperationQueue *queue = [NSOperationQueue new];
    Calculator *calculator  = [[Calculator new] onQueue:queue];
    XCTAssertThrows([[calculator divide:10 by:0] doubleValue], @"Expected division by 0 exception");
}

- (void)testWillPropogateExceptionsFromDispatchQueue
{
    Calculator *calculator  = [[Calculator new] dispatchGlobal];
    XCTAssertThrows([[calculator divide:10 by:0] doubleValue], @"Expected division by 0 exception");
}

- (void)testCanGetAsyncResultForInvocaion
{
    id<MKAsyncResult> __autoreleasing asyncResult;
    [[(id<MKAsyncObject>)[[Calculator new] inNewThread] outAsyncResult:&asyncResult] addSimple:5 to:6];
    XCTAssertNotNil(asyncResult, @"AsyncResult nil");
    int sum;
    [asyncResult.result getValue:&sum];
    XCTAssertEqual(11, sum, @"Sum should be 11");
}

- (void)testWillGetNotifiedWhenInvocationComplete
{
    id<MKAsyncResult> __autoreleasing asyncResult;
    [[(id<MKAsyncObject>)[[Calculator new] inNewThread] outAsyncResult:&asyncResult] addSimple:5 to:6];
    [[asyncResult promise] done:^(NSValue *result) {
        int sum;
        [result getValue:&sum];
        XCTAssertEqual(11, sum, @"Sum should be 11");
    }];
    XCTAssertNotNil(asyncResult, @"AsyncResult nil");
}

- (void)testCanExecuteBlockOnNewThread
{
    Calculator *calculator = [Calculator new];
    
    [[MKAction inNewThread] do:^{
        XCTAssertFalse([[calculator isOnMainThread] boolValue],  @"Calculation should not be on main thread");
    }];
}

- (void)testCanExecuteBlockOnOperationQueue
{
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [[MKAction onQueue:queue] do:^{
        XCTAssertEqual(queue, [NSOperationQueue currentQueue], @"Block not executed on right queue");
    }];
}

- (void)testCanExecuteBlockOnDispatchQueue
{
    [[MKAction dispatchGlobal] do:^{
        XCTAssertFalse([NSThread isMainThread], @"Block not executed on right queue");
    }];
}

- (void)testCanExecuteBlockUsingCustomStartegy
{
    TestAsyncDelegate *testStrategy = [TestAsyncDelegate new];
    
    [[MKAction concurrent:testStrategy] do:^{
        // Nothing
    }];
    
    XCTAssertNotNil(testStrategy.asyncResult, @"AsyncResult is nil");
}

- (void)testCanNestInvocationsWithDifferentConcurrencyStrategues
{
    MKAction         *action = [MKAction new];
    NSOperationQueue *queue  = [NSOperationQueue new];
    
    [[action onQueue:queue] do:^{
        XCTAssertEqual(queue, [NSOperationQueue currentQueue], @"Block not executed on right queue");
        [[action onMainThread] do:^{
            XCTAssertTrue([NSThread isMainThread],  @"Block not exectued on main thread");
        }];
    }];
}

@end
