//
//  MKDeferredTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/9/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MirukenConcurrency.h"

@interface MKDeferredTests : XCTestCase

@end

@implementation MKDeferredTests


- (void)testDeferredInitiallyPending
{
    MKDeferred *deferred = [MKDeferred new];
    XCTAssertEqual(MKPromiseStatePending, deferred.state, @"state should be pending");
}

- (void)testCanResolveDeferred
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred resolve];
    XCTAssertEqual(MKPromiseStateResolved, deferred.state, @"state should be resolved");
}

- (void)testCanResolveDeferredOnlyOnce
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred resolve];
    XCTAssertThrowsSpecificNamed([deferred resolve], NSException, NSInternalInconsistencyException,
                                 @"Deferred resolve can only be called once");
}

- (void)testCanRejectDeferred
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertEqual(MKPromiseStateRejected, deferred.state, @"state should be rejected");
}

- (void)testCanRejectDeferredOnlyOnce
{
    MKDeferred *deferred = [MKDeferred new];
    NSError    *error    = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred reject:error];
    XCTAssertThrowsSpecificNamed([deferred reject:error], NSException, NSInternalInconsistencyException,
                                 @"Deferred reject can only be called once");
}

- (void)testCanCancelDeferred
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred cancel];
    XCTAssertEqual(MKPromiseStateCancelled, deferred.state, @"state should be cancelled");
}

- (void)testCanCancelMoreThanOnce
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred cancel];
    XCTAssertNoThrow([deferred cancel], @"Deferred cancel can be called more than once");
}

- (void)testCancelIgnoredIfAlreadyResolved
{
    MKDeferred *deferred = [MKDeferred resolved];
    XCTAssertNoThrow([deferred cancel], @"Deferred cancel can be called if already resolved");
    XCTAssertEqual(MKPromiseStateResolved, deferred.state, @"state should be resolved");
}

- (void)testCancelIgnoredIfAlreadyRejected
{
    MKDeferred *deferred = [MKDeferred rejected:nil];
    XCTAssertNoThrow([deferred cancel], @"Deferred cancel can be called if already rejected");
    XCTAssertEqual(MKPromiseStateRejected, deferred.state, @"state should be rejected");
}

- (void)testResolveIgnoredIfAlreadyCancelled
{
    __block BOOL  doneCalled = NO;
    MKDeferred   *deferred   = [[MKDeferred new] done:^(id result) { doneCalled = YES; }];
    [deferred cancel];
    XCTAssertNoThrow([deferred resolve:nil], @"Deferred resolve ignored if already cancelled");
    XCTAssertEqual(MKPromiseStateCancelled, deferred.state, @"state should be cancelled");
    XCTAssertFalse(doneCalled, @"done callbacks should not be called");
}

- (void)testRejectIgnoredIfAlreadyCancelled
{
    __block BOOL  failCalled = NO;
    MKDeferred   *deferred   = [[MKDeferred new] fail:^(id reason, BOOL *handled) {
        failCalled = YES;
    }];
    [deferred cancel];
    XCTAssertNoThrow([deferred reject:nil], @"Deferred reject ignored if already cancelled");
    XCTAssertEqual(MKPromiseStateCancelled, deferred.state, @"state should be cancelled");
    XCTAssertFalse(failCalled, @"fail callbacks should not be called");
}

- (void)testCannotResolveDeferredOnceRejected
{
    MKDeferred *deferred = [MKDeferred rejected:nil];
    XCTAssertThrowsSpecificNamed([deferred resolve], NSException, NSInternalInconsistencyException,
                                 @"Deferred cannot be resolved once rejected");
}

- (void)testCannotRejectDeferredOnceResolved
{
    MKDeferred *deferred = [[MKDeferred new] resolve];
    XCTAssertThrowsSpecificNamed([deferred reject:nil], NSException, NSInternalInconsistencyException,
                                 @"Deferred cannot be rejected once resolved");
}

- (void)testWillCallDoneCallbacksWhenDeferredResolved
{
    __block id  resolved = nil;
    MKDeferred *deferred = [[MKDeferred new] done:^(id result) { resolved = result; }];
    XCTAssertNil(resolved, @"Deferred not resolved yet");
    [deferred resolve:@"Hello"];
    XCTAssertEqualObjects(@"Hello", resolved, @"Deferred done callbacks not called");
}

- (void)testWillCallDoneCallbacksWhenDeferredlreadyResolved
{
    __block id  resolved = nil;
    MKDeferred *deferred = [[MKDeferred new] resolve:@"Hello"];
    [deferred done:^(id result) { resolved = result; }];
    XCTAssertEqualObjects(@"Hello", resolved, @"Deferred done callbacks not called");
}

- (void)testWillCallDoneCallbacksWithMatchingClassConstraint
{
    __block id  resolved = nil;
    MKDeferred *deferred = [[MKDeferred new] resolve:@"Hello"];
    [deferred done:NSString.class:^(id result) { resolved = result; }];
    XCTAssertEqualObjects(@"Hello", resolved, @"Deferred done callbacks not called");
}

- (void)testWillNotCallDoneCallbacksWithUnmatchedClassConstraint
{
    __block id  resolved = nil;
    MKDeferred *deferred = [[MKDeferred new] resolve:@"Hello"];
    [deferred done:NSDictionary.class:^(id result) { resolved = result; }];
    XCTAssertNil(resolved, @"Deferred done callbacks called");
}

- (void)testWillCallDoneCallbacksWithMatchingProtocolConstraint
{
    __block id  resolved = nil;
    MKDeferred *deferred = [[MKDeferred new] resolve:@"Hello"];
    [deferred done:@protocol(NSCopying):^(id result) { resolved = result; }];
    XCTAssertEqualObjects(@"Hello", resolved, @"Deferred done callbacks not called");
}

- (void)testWillNotCallDoneCallbacksWithUnmatchedProtocolConstraint
{
    __block id  resolved = nil;
    MKDeferred *deferred = [[MKDeferred new] resolve:@"Hello"];
    [deferred done:@protocol(NSFastEnumeration):^(id result) { resolved = result; }];
    XCTAssertNil(resolved, @"Deferred done callbacks called");
}

- (void)testWillCallFailCallbacksWhenDeferredRejected
{
    __block NSError *rejected = nil;
    MKDeferred      *deferred = [[MKDeferred new] error:^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertNil(rejected, @"Deferred not rejected yet");
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Deferred fail callbacks not called");
}

- (void)testWillCallFailCallbacksWhenDeferredAlreadyRejected
{
    __block NSError *rejected = nil;
    NSError         *error    = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    MKDeferred      *deferred = [MKDeferred rejected:error];
    [deferred error:^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Deferred fail callbacks not called");
}

- (void)testWillCallFailCallbacksWithMatchingClassConstraint
{
    __block NSError *rejected = nil;
    MKDeferred      *deferred = [MKDeferred new];
    [deferred fail:NSError.class:^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertNil(rejected, @"Deferred not rejected yet");
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Deferred fail callbacks not called");
}

- (void)testWillNotCallFailCallbacksWithUnmatchingClassConstraint
{
    __block NSError *rejected = nil;
    MKDeferred      *deferred = [MKDeferred new];
    [deferred fail:NSException.class:^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertNil(rejected, @"Deferred not rejected yet");
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertNil(rejected, @"Deferred fail callbacks called");
}

- (void)testWillCallFailCallbacksWithMatchingProtocolConstraint
{
    __block NSError *rejected = nil;
    MKDeferred      *deferred = [MKDeferred new];
    [deferred fail:@protocol(NSCopying):^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertNil(rejected, @"Deferred not rejected yet");
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Deferred fail callbacks not called");
}

- (void)testWillNotCallFailCallbacksWithUnmatchingProtocolConstraint
{
    __block NSError *rejected = nil;
    MKDeferred *deferred = [MKDeferred new];
    [deferred fail:@protocol(NSFastEnumeration):^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertNil(rejected, @"Deferred not rejected yet");
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertNil(rejected, @"Deferred fail callbacks called");
}

- (void)testWillCallFailCallbacksWhenDeferredCancelled
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred  = [[MKDeferred new] cancel:^{ cancelled = YES; }];
    XCTAssertFalse(cancelled, @"Deferred not cancelled yet");
    [deferred cancel];
    XCTAssertTrue(cancelled, @"Deferred cancel callbacks not called");
}

- (void)testWillCallFailCallbacksWhenDeferredAlreadyCancelled
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred  = [MKDeferred new];
    [deferred cancel];
    [deferred cancel:^{ cancelled = YES; }];
    XCTAssertTrue(cancelled, @"Deferred cancel callbacks not called");
}

- (void)testWillCallAlwaysCallbacksWhenDeferredResolved
{
    __block BOOL  resolved = NO;
    MKDeferred   *deferred = [[MKDeferred new] always:^{ resolved = YES; }];
    XCTAssertFalse(resolved, @"Deferred not resolved yet");
    [deferred resolve:@"Hello"];
    XCTAssertTrue(resolved, @"Deferred always callbacks not called when resolved");
}

- (void)testWillCallAlwaysCallbacksWhenDeferredRejected
{
    __block BOOL  rejected = NO;
    MKDeferred   *deferred = [[MKDeferred new] always:^{ rejected = YES; }];
    XCTAssertFalse(rejected, @"Deferred not rejected yet");
    [deferred reject:nil];
    XCTAssertTrue(rejected, @"Deferred always callbacks not called when rejected");
}

- (void)testWillCallAlwaysCallbacksWhenDeferredCancelled
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred  = [[MKDeferred new] always:^{ cancelled = YES; }];
    XCTAssertFalse(cancelled, @"Deferred not cancelled yet");
    [deferred cancel];
    XCTAssertTrue(cancelled, @"Deferred always callbacks not called when cancelled");
}

- (void)testWillCallAlwaysCallbacksWhenDeferredAlreadyResolved
{
    __block BOOL  resolved = NO;
    MKDeferred   *deferred = [[MKDeferred new] resolve:@"Hello"];
    [deferred always:^{ resolved = YES; }];
    XCTAssertTrue(resolved, @"Deferred always callbacks not called when resolved already");
}

- (void)testWillCallAlwaysCallbacksWhenDeferredRejectedAlready
{
    __block BOOL  rejected = NO;
    MKDeferred   *deferred = [MKDeferred rejected:nil];
    [deferred always:^{ rejected = YES; }];
    XCTAssertTrue(rejected, @"Deferred always callbacks not called when rejected already");
}

- (void)testWillCallAlwaysCallbacksWhenDeferredCancelledAlready
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred  = [MKDeferred new];
    [deferred cancel];
    [deferred always:^{ cancelled = YES; }];
    XCTAssertTrue(cancelled, @"Deferred always callbacks not called when cancelled already");
}

- (void)testPromisePending
{
    MKPromise promise = [[MKDeferred new] promise];
    XCTAssertEqual(MKPromiseStatePending, promise.state, @"state should be pending");
}

- (void)testPromiseResolved
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred resolve];
    MKPromise   promise  = [deferred promise];
    XCTAssertEqual(MKPromiseStateResolved, promise.state, @"state should be resolved");
}

- (void)testPromiseRejected
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    MKPromise   promise  = [deferred promise];
    XCTAssertEqual(MKPromiseStateRejected, promise.state, @"state should be rejected");
}

- (void)testPromiseCancelled
{
    MKDeferred *deferred = [MKDeferred new];
    [deferred cancel];
    MKPromise   promise  = [deferred promise];
    XCTAssertEqual(MKPromiseStateCancelled, promise.state, @"state should be cancelled");
}

- (void)testWillCallDonePromiseWhenDeferredResolved
{
    __block id  resolved = nil;
    MKDeferred *deferred = [MKDeferred new];
    [[deferred promise] done:^(id result) { resolved = result; }];
    XCTAssertNil(resolved, @"Deferred not resolved yet");
    [deferred resolve:@"Hello"];
    XCTAssertEqualObjects(@"Hello", resolved, @"promise done callbacks not called");
}

- (void)testWillCallFailPromiseWhenDeferredRejected
{
    __block NSError *rejected = nil;
    MKDeferred      *deferred = [MKDeferred new];
    [[deferred promise] error:^(NSError *error, BOOL *handled) { rejected = error; }];
    XCTAssertNil(rejected, @"Deferred not rejected yet");
    [deferred reject:[NSError errorWithDomain:@"Foo" code:1 userInfo:nil]];
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Deferred fail callbacks not called");
}

- (void)testWillCallFailPromiseWhenDeferredCancelled
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred  = [MKDeferred new];
    [[deferred promise] cancel:^{ cancelled = YES; }];
    XCTAssertFalse(cancelled, @"Deferred not cancelled yet");
    [deferred cancel];
    XCTAssertTrue(cancelled, @"Deferred cancel callbacks not called");
}

- (void)testWillCallAlwaysPromiseWhenDeferredResolved
{
    __block BOOL  resolved = NO;
    MKDeferred   *deferred = [MKDeferred new];
    [[deferred promise] always:^{ resolved = YES; }];
    XCTAssertFalse(resolved, @"Deferred not resolved yet");
    [deferred resolve:@"Hello"];
    XCTAssertTrue(resolved, @"promise always callbacks not called");
}

- (void)testWillCallAlwaysPromiseWhenDeferredRejected
{
    __block BOOL  rejected = NO;
    MKDeferred   *deferred = [MKDeferred new];
    [[deferred promise] always:^{ rejected = YES; }];
    XCTAssertFalse(rejected, @"Deferred not rejected yet");
    [deferred reject:nil];
    XCTAssertTrue(rejected, @"promise always callbacks not called");
}

- (void)testWillCallAlwaysPromiseWhenDeferredCancelled
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred  = [MKDeferred new];
    [[deferred promise] always:^{ cancelled = YES; }];
    XCTAssertFalse(cancelled, @"Deferred not cancelled yet");
    [deferred cancel];
    XCTAssertTrue(cancelled, @"promise always callbacks not called");
}

- (void)testWillNotifyProgress
{
    __block NSUInteger  step      = 0;
    MKDeferred          *deferred = [MKDeferred new];
    [[deferred promise] progress:^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    [deferred notify:@(5U)];
    XCTAssertEqual(5U, step, @"Expected step 5");
    [deferred notify:@(9U)];
    XCTAssertEqual(9U, step, @"Expected step 9");
}

- (void)testWillNotifyProgressWithMatchingClassConstraint
{
    __block NSUInteger  step     = 0;
    MKDeferred         *deferred = [MKDeferred new];
    [[deferred promise] progress:NSNumber.class:^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    [deferred notify:@(5U)];
    XCTAssertEqual(5U, step, @"Expected step 5");
    [deferred notify:@(9U)];
    XCTAssertEqual(9U, step, @"Expected step 9");
}

- (void)testWillNotNotifyProgressWithUnmatchingClassConstraint
{
    __block NSUInteger  step     = 0;
    MKDeferred         *deferred = [MKDeferred new];
    [[deferred promise] progress:NSDictionary.class:^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    [deferred notify:@(5U)];
    XCTAssertEqual(0U, step, @"Unexpected notification");
}

- (void)testWillNotifyProgressWithMatchingProtocolConstraint
{
    __block NSUInteger  step     = 0;
    MKDeferred         *deferred = [MKDeferred new];
    [[deferred promise] progress:@protocol(NSCopying):^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    [deferred notify:@(5U)];
    XCTAssertEqual(5U, step, @"Expected step 5");
    [deferred notify:@(9U)];
    XCTAssertEqual(9U, step, @"Expected step 9");
}

- (void)testWillNotNotifyProgressWithUnmatchingProtocolConstraint
{
    __block NSUInteger  step     = 0;
    MKDeferred         *deferred = [MKDeferred new];
    [[deferred promise] progress:@protocol(NSFastEnumeration):^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    [deferred notify:@(5U)];
    XCTAssertEqual(0U, step, @"Unexpected notification");
}

- (void)testWillNotQueueNotificationsByDefault
{
    __block NSUInteger  step      = 0;
    MKDeferred          *deferred = [MKDeferred new];
    [deferred notify:@(5U)];
    [[deferred promise] progress:^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    XCTAssertEqual(0U, step, @"Expected step 5");
}

- (void)testCanQueueNotifications
{
    __block NSUInteger  step      = 0;
    MKDeferred          *deferred = [MKDeferred new];
    [deferred notify:@(5U) queue:YES];
    [[deferred promise] progress:^(NSNumber *progress, BOOL queued) {
        step = [progress unsignedIntegerValue];
    }];
    XCTAssertEqual(5U, step, @"Expected step 5");
}

- (void)testCanProjectPromiseWhenResolved
{
    __block NSString *message;
    MKDeferred       *deferred = [MKDeferred new];
    [[deferred then:^(NSString *result) {
        return [NSString stringWithFormat:@"Hello %@", result];
    }] done:^(NSString *result) {
        message = result;
    }];
    [deferred resolve:@"Craig"];
    XCTAssertEqualObjects(@"Hello Craig", message, @"Pipe failed");
}

- (void)testCanChainProjectionsWhenResolved
{
    __block NSString *message;
    MKDeferred       *deferred = [MKDeferred new];
    [[[deferred then:^(NSString *result) {
        return [NSString stringWithFormat:@"Hello %@", result];
    }] then:^(NSString *result) {
        return [result lowercaseString];
    }] done:^(NSString *result) {
        message = result;
    }];
    [deferred resolve:@"Craig"];
    XCTAssertEqualObjects(@"hello craig", message, @"Pipe failed");
}

- (void)testCanChainPromiseWhenPipeResolved
{
    __block NSString *message;
    MKDeferred       *deferred1 = [MKDeferred new];
    
    [[deferred1 then:^(NSString *result) {
        return [MKDeferred resolved:[NSString stringWithFormat:@"Hello %@", result]];
    }] done:^(NSString *result) {
        message = result;
    }];
    [deferred1 resolve:@"Craig"];
    XCTAssertEqualObjects(@"Hello Craig", message, @"Pipe failed");
}

- (void)testWillFailChainWhenPipeRejected
{
    __block NSError *rejected  = nil;
    MKDeferred      *deferred1 = [MKDeferred new];
    
    [[deferred1 then:^(NSString *result) {
        NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
        return [MKDeferred rejected:error];
    }] error:^(NSError *error, BOOL *handled) {
        rejected = error;
    }];
    [deferred1 resolve:@"Craig"];
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Deferred fail callbacks not called");
}

- (void)testWillFailChainWhenPipeCancelled
{
    __block BOOL  cancelled = NO;
    MKDeferred   *deferred1 = [MKDeferred new];
    
    [[deferred1 then:^(NSString *result) {
        MKDeferred *deferred2 = [MKDeferred new];
        [deferred2 cancel];
        return [deferred2 promise];
    }] cancel:^{
        cancelled = YES;
    }];
    [deferred1 resolve:@"Craig"];
    XCTAssertTrue(cancelled, @"Deferred cancel callbacks not called");
}

- (void)testCanProjectPromiseWhenNotified
{
    __block NSString *message;
    MKDeferred       *deferred = [MKDeferred new];
    [[deferred then:nil failFilter:nil progressFilter:^(NSNumber *progress, BOOL *queued) {
        return [NSString stringWithFormat:@"Step %@ complete", progress];
    }] progress:^(NSString *progress, BOOL queued)
     {
         message = progress;
     }];
    [deferred notify:@(6U)];
    XCTAssertEqualObjects(@"Step 6 complete", message, @"Pipe notify failed");
}

- (void)testWillResolveAggregateWhenAllResolved
{
    __block BOOL  resolved  = NO;
    MKDeferred   *deferred1 = [MKDeferred new];
    MKDeferred   *deferred2 = [MKDeferred new];
    
    [[MKDeferred whenAll:@[deferred1, deferred2]]
     done:^(id result) { resolved = YES; }];
    
    XCTAssertFalse(resolved, @"Should not be resolved yet");
    [deferred1 resolve:@"Hello"];
    XCTAssertFalse(resolved, @"Should not be resolved yet");
    [deferred2 resolve:@"Hello"];
    
    XCTAssertTrue(resolved, @"Master should be resolved");
}

- (void)testWillPassAllResolvedAggregateWhenResolved
{
    __block NSArray *aggregate  = nil;
    MKDeferred      *deferred1 = [MKDeferred new];
    MKDeferred      *deferred2 = [MKDeferred new];
    
    [[MKDeferred whenAll:@[deferred1, deferred2]]
     done:^(NSArray *result) { aggregate = result; }];
    
    XCTAssertNil(aggregate, @"Should not be resolved yet");
    [deferred1 resolve:@"Hello"];
    XCTAssertNil(aggregate, @"Should not be resolved yet");
    [deferred2 resolve:@"World"];
    
    XCTAssertTrue([aggregate isEqualToArray:(@[@"Hello", @"World"])], @"Master should be resolved");
}

- (void)testWillRejectAggregateWhenAnyRejected
{
    __block NSError *rejected  = nil;
    MKDeferred      *deferred1 = [MKDeferred new];
    MKDeferred      *deferred2 = [MKDeferred new];
    
    [[MKDeferred whenAll:@[deferred1, deferred2]]
     error:^(NSError *error, BOOL *handled) { rejected = error; }];
    
    [deferred2 resolve:@"Hello"];
    
    XCTAssertNil(rejected, @"Should not be rejected yet");
    NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred1 reject:error];
    
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Master deferred fail not called");
}

- (void)testWillCancelAggregateWhenAnyCancelled
{
    __block  BOOL  cancelled = NO;
    MKDeferred    *deferred1 = [MKDeferred new];
    MKDeferred    *deferred2 = [MKDeferred new];
    
    [[MKDeferred whenAll:@[deferred1, deferred2]] cancel:^{ cancelled = YES; }];
    [deferred2 resolve:@"Hello"];
    
    XCTAssertFalse(cancelled, @"Should not be cancelled yet");
    [deferred1 cancel];
    
    XCTAssertTrue(cancelled, @"Master deferred cancelled not called");
}

- (void)testWillRejectAggregateWhenAnyAlreadyRejected
{
    __block NSError *rejected  = nil;
    MKDeferred      *deferred1 = [MKDeferred new];
    MKDeferred      *deferred2 = [MKDeferred new];
    
    NSError *error = [NSError errorWithDomain:@"Foo" code:1 userInfo:nil];
    [deferred1 reject:error];
    [deferred2 resolve:@"Hello"];
    
    [[MKDeferred whenAll:@[deferred1, deferred2]]
        error:^(NSError *error, BOOL *handled) { rejected = error; }];
    
    XCTAssertEqualObjects(@"Foo", rejected.domain, @"Master deferred fail not called");
}

- (void)testWillCancelAggregateWhenAnyAlreadyCancelled
{
    __block  BOOL  cancelled = NO;
    MKDeferred    *deferred1 = [MKDeferred new];
    MKDeferred    *deferred2 = [MKDeferred new];
    
    [deferred1 cancel];
    [deferred2 resolve:@"Hello"];
    
    [[MKDeferred whenAll:@[deferred1, deferred2]] cancel:^{ cancelled = YES; }];
    
    XCTAssertTrue(cancelled, @"Master deferred cancelled not called");
}

- (void)testCanPoxyDeferredOnNewThread
{
    MKDeferred *deferred = [[[MKDeferred new] inNewThread]
        done:^(id result) {
            XCTAssertFalse([[NSThread currentThread] isMainThread], @"Should not be main thread");
        }];
    XCTAssertFalse(deferred.state == MKPromiseStateResolved, @"Deferred not resolved yet");
    [deferred resolve:@"Hello"];
}

- (void)testCanPoxyPromiseDoneOnNewThread
{
    MKDeferred *deferred = [[MKDeferred new] inNewThread];
    [[[deferred promise] done:^(id result) {
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"Done should not be main thread");
    }]
     always:^{
         XCTAssertFalse([[NSThread currentThread] isMainThread], @"Always should not be main thread");
     }];
    [deferred resolve:@"Hello"];
}

- (void)testCanPoxyPromiseFailOnNewThread
{
    MKDeferred *deferred = [[MKDeferred new] inNewThread];
    [[[deferred promise] fail:^(id reason, BOOL *handled) {
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"Fail should not be main thread");
    }]
     always:^{
         XCTAssertFalse([[NSThread currentThread] isMainThread], @"Always should not be main thread");
     }];
    [deferred reject:nil];
}

- (void)testCanPoxyPromiseCancelOnNewThread
{
    MKDeferred *deferred = [[MKDeferred new] inNewThread];
    [[[deferred promise] cancel:^{
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"Cancel should not be main thread");
    }]
     always:^{
         XCTAssertFalse([[NSThread currentThread] isMainThread], @"Always should not be main thread");
     }];
    [deferred cancel];
}

- (void)testCanProjectPromiseWhenResolvedOnNewThread
{
    MKDeferred *deferred = [[MKDeferred new] inNewThread];
    [[deferred then:^(NSString *result) {
        return [NSString stringWithFormat:@"Hello %@", result];
    }] done:^(NSString *result) {
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"Done should not be main thread");
        XCTAssertEqualObjects(@"Hello Craig", result, @"Pipe failed");
    }];
    [deferred resolve:@"Craig"];
}

- (void)testCanChainProjectionsWhenResolvedOnNewThread
{
    MKDeferred *deferred = [[MKDeferred new] inNewThread];
    [[[deferred then:^(NSString *result) {
        return [NSString stringWithFormat:@"Hello %@", result];
    }] then:^(NSString *result) {
        return [result lowercaseString];
    }] done:^(NSString *result) {
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"Done should not be main thread");
        XCTAssertEqualObjects(@"hello craig", result, @"Pipe failed");
    }];
    [deferred resolve:@"Craig"];
}

@end
