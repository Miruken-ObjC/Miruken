//
//  MKBufferedPromiseTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MirukenConcurrency.h"

@interface MKBufferedPromiseTests : XCTestCase

@end

@implementation MKBufferedPromiseTests


- (void)testWillCreateBufferedDeferred
{
    MKDeferred *deferred = [MKDeferred new];
    id          buffer   = [deferred buffer];
    XCTAssertTrue([buffer conformsToProtocol:@protocol(MKBufferedPromise)], @"Not a buffered Deferred");
}

- (void)testWillCreateBufferedPromise
{
    MKDeferred *deferred = [MKDeferred new];
    id          buffer   = [[deferred promise] buffer];
    XCTAssertTrue([buffer conformsToProtocol:@protocol(MKBufferedPromise)], @"Not a buffered Promise");
}

- (void)testWillCreateBufferedPipe
{
    MKDeferred *deferred = [MKDeferred new];
    id          buffer   = [[[deferred promise] then:^(id result) {
        return [[MKDeferred new] promise];
    }] buffer];
    XCTAssertTrue([buffer conformsToProtocol:@protocol(MKBufferedPromise)], @"Not a buffered Pipe");
}

- (void)testCanBufferPromiseDone
{
    __block id result;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer]
                                       bufferDone:^(id _result) { result = _result; }];
    
    [deferred resolve:@"Hello"];
    XCTAssertNil(result, @"Buffered done was called");
    
    [buffer flush];
    XCTAssertEqualObjects(@"Hello", result, @"Done callback never called");
}

- (void)testPromiseDoneCalledImmediately
{
    __block id result;
    
    MKDeferred *deferred = [MKDeferred new];
    [[[deferred promise] buffer] done:^(id _result) { result = _result; }];
    [deferred resolve:@"Hello"];
    XCTAssertEqualObjects(@"Hello", result, @"Done callback never called");
}

- (void)testCanBufferPromiseFail
{
    __block id reason;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer]
                                       bufferFail:^(id _reason, BOOL *handled) { reason = _reason; }];
    
    NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred reject:error];
    XCTAssertNil(reason, @"Buffered fail was called");
    
    [buffer flush];
    XCTAssertEqualObjects(error, reason, @"Fail callback never called");
}

- (void)testPromiseFailCalledImmediately
{
    __block id reason;
    
    MKDeferred *deferred = [MKDeferred new];
    [[[deferred promise] buffer] fail:^(id _reason, BOOL *handled) { reason = _reason; }];
    
    NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred reject:error];
    XCTAssertEqualObjects(error, reason, @"Fail callback never called");
}

- (void)testCanBufferPromiseCancel
{
    __block BOOL cancelled = NO;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer] bufferCancel:^{ cancelled = YES; }];
    
    [deferred cancel];
    XCTAssertFalse (cancelled, @"Buffered cancel was called");
    
    [buffer flush];
    XCTAssertTrue(cancelled, @"Buffered cancel was not called");
}

- (void)testPromiseCancelCalledImmediately
{
    __block BOOL cancelled = NO;
    
    MKDeferred *deferred = [MKDeferred new];
    [[[[deferred promise] buffer] cancel:^{ cancelled = YES; }] cancel];
    XCTAssertTrue(cancelled, @"Buffered cancel was not called");
    
}

- (void)testCanBufferPromiseAlwaysOnResolve
{
    __block BOOL always = NO;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer] bufferAlways:^{ always = YES; }];
    
    [deferred resolve:nil];
    XCTAssertFalse(always, @"Buffered always was called");
    
    [buffer flush];
    XCTAssertTrue(always, @"Always callback never called");
}

- (void)testCanBufferPromiseAlwaysOnReject
{
    __block BOOL always = NO;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer] bufferAlways:^{ always = YES; }];
    
    [deferred reject:nil];
    XCTAssertFalse(always, @"Buffered always was called");
    
    [buffer flush];
    XCTAssertTrue(always, @"Always callback never called");
}

- (void)testCanBufferPromiseProgress
{
    __block id progress;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer]
                                       bufferProgress:^(id _progress, BOOL queued) {
                                           progress = _progress;
                                       }];
    
    [deferred notify:@"Hello"];
    XCTAssertNil(progress, @"Buffered progress was called");
    
    [buffer flush];
    XCTAssertEqualObjects(@"Hello", progress, @"Progress callback never called");
}

- (void)testPropogateDoneIfAlreadyFlushed
{
    __block id result;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer]
                                       bufferDone:^(id _result) { result = _result; }];
    
    [buffer flush];
    [deferred resolve:@"Hello"];
    
    XCTAssertEqualObjects(@"Hello", result, @"Done callback never called");
}

- (void)testPropogateFailIfAlreadyFlushed
{
    __block id reason;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer]
                                       bufferFail:^(id _reason, BOOL *handled) {
                                           reason = _reason;
                                       }];
    
    [buffer flush];
    NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred reject:error];
    
    XCTAssertEqualObjects(error, reason, @"Fail callback never called");
}

- (void)testPropogateProgressIfAlreadyFlushed
{
    __block id progress;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[[deferred promise] buffer]
                                       bufferProgress:^(id _progress, BOOL queued) {
                                           progress = _progress;
                                       }];
    
    [buffer flush];
    [deferred notify:@"Hello"];
    
    XCTAssertEqualObjects(@"Hello", progress, @"Progress callback never called");
}

- (void)testCallDoneIfAlreadyFlushed
{
    __block id result;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[deferred promise] buffer];
    
    [buffer flush];
    [deferred resolve:@"Hello"];
    [buffer bufferDone:^(id _result) { result = _result; }];
    
    XCTAssertEqualObjects(@"Hello", result, @"Done callback never called");
}

- (void)testCallFailIfAlreadyFlushed
{
    __block id reason;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[deferred promise] buffer];
    
    [buffer flush];
    NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred reject:error];
    [buffer bufferFail:^(id _reason, BOOL *handled) { reason = _reason; }];
    
    XCTAssertEqualObjects(error, reason, @"Fail callback never called");
}

- (void)testCallCancelIfAlreadyFlushed
{
    __block BOOL cancelled = NO;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[deferred promise] buffer];
    
    [buffer flush];
    [deferred cancel];
    [buffer bufferCancel:^{ cancelled = YES; }];
    
    XCTAssertTrue(cancelled, @"Cancel callback never called");
}

- (void)testCallProgressIfAlreadyFlushed
{
    __block id progress;
    
    MKDeferred            *deferred = [MKDeferred new];
    id<MKBufferedPromise>  buffer   = [[deferred promise] buffer];
    
    [buffer flush];
    [deferred notify:@"Hello" queue:YES];
    [buffer bufferProgress:^(id _progress, BOOL queued) { progress = _progress; }];
    
    XCTAssertEqualObjects(@"Hello", progress, @"Progress callback never called");
}

@end
