//
//  MKContextTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Miruken.h"
#import "Configuration.h"
#import "SomeViewController.h"
#import "SomeContextualObject.h"
#import "ConfigurationCallbackHandler.h"

BOOL deallocCalled;

@interface MyContext : MKContext

@end

@implementation MyContext

+ (void)initialize
{
    if (self == MyContext.class)
    {
        // Mix-in contextual capabilities
        
        [UIViewController       mixinFrom:MKContextualMixin.class];
        [UIViewController       mixinFrom:UIViewController_ContextualMixin.class];
        [UINavigationController mixinFrom:UINavigationController_ContextualMixin.class];
    }
}

- (void)dealloc
{
    deallocCalled = YES;
}

@end

@interface MKContextTests : XCTestCase

@end

@implementation MKContextTests
{
    MKContext *rootContext;
}

- (void)setUp
{
    [super setUp];
    
    deallocCalled = NO;
    rootContext = [MyContext new];
}

- (void)tearDown
{
    [super tearDown];
    
    [rootContext end];
    rootContext = nil;
}


- (void)testCanCreateChildContext
{
    MKContext *childContext = [rootContext newChildContext];
    XCTAssertNotNil(childContext, @"child context was nil");
    XCTAssertEqual(rootContext, childContext.parent, @"missing or wrong parent context");
}

- (void)testCanDetermineIfContextHasChildren
{
    XCTAssertFalse([rootContext hasChildren], @"context has no children");
    MKContext *childContext = [rootContext newChildContext];
    XCTAssertTrue([rootContext hasChildren], @"context has children");
    [childContext end];
    XCTAssertFalse([rootContext hasChildren], @"context has no children");
}

- (void)testCanObtainRootContext;
{
    MKContext *childContext = [[rootContext newChildContext] newChildContext];
    XCTAssertEqualObjects(rootContext, childContext.rootContext, @"Root context wrong");
}

- (void)testContextCanHandleItself
{
    MKContext *context;
    BOOL handled = [rootContext tryGetClass:MKContext.class into:&context];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqual(rootContext, context, @"contexts don't match");
}

- (void)testCanHandleCallbacks
{
    [rootContext addHandler:[ConfigurationCallbackHandler new]];
    
    Configuration *config = [Configuration new];
    BOOL          handled = [rootContext handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testChildContextChainedToParent
{
    [rootContext addHandler:[ConfigurationCallbackHandler new]];
    MKContext *childContext = [rootContext newChildContext];
    
    Configuration *config = [Configuration new];
    BOOL          handled = [childContext handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanDelegateDynamicCallbacks
{
    SomeViewController *someController = [SomeViewController newInChildContext:rootContext];
    Configuration      *config;
    BOOL                handled        = [someController.context tryGetClass:Configuration.class
                                                                        into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.improving.com", @"expected url www.improving.com");
}

- (void)testCanBreakDynamicDelegation
{
    SomeViewController *someController = [SomeViewController newInChildContext:rootContext];
    Configuration      *config;
    BOOL                handled        = [someController.context tryGetClass:Configuration.class
                                                                        into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.improving.com", @"expected url www.improving.com");
    
    someController.context             = nil;
    handled                            = [someController.context tryGetClass:Configuration.class
                                                                        into:&config];
    XCTAssertFalse(handled, @"The callback was handled");
}

- (void)testChildContextWillCleanUp
{
    XCTAssertFalse(deallocCalled, @"Context dealloc was called");
    @autoreleasepool {
        [[rootContext newChildContext] end];
    }
    XCTAssertTrue(deallocCalled, @"Context dealloc not called");
}

- (void)testChildContextWithHandlerWillCleanUp
{
    XCTAssertFalse(deallocCalled, @"Context dealloc was called");
    @autoreleasepool {
        MKContext *childContext = [rootContext newChildContext];
        [childContext addHandler:[Configuration accept:^(Configuration *config,
                                                         id<MKCallbackHandler> composition)
                                  {
                                      config.url = @"www.soccer.com";
                                      return YES;
                                  }]];
        [childContext end];
        childContext = nil;
    }
    XCTAssertTrue(deallocCalled, @"Context dealloc not called");
}

- (void)testViewControllerContextWillCleanUp
{
    XCTAssertFalse(deallocCalled, @"Context dealloc was called");
    @autoreleasepool {
        SomeViewController *someController = [SomeViewController newInChildContext:rootContext];
        [someController.context
         addHandler:[Configuration accept:^(Configuration *config, id<MKCallbackHandler> composition)
                     {
                         config.url = @"www.soccer.com";
                         return YES;
                     }]];
        someController = nil;
    }
    XCTAssertTrue(deallocCalled, @"Context dealloc not called");
}

- (void)testCanReceiveNotifiedWhenContextWillEnd
{
    __block BOOL contextWillEnd = NO;
    MKContext *context = [rootContext newChildContext];
    [context subscribe:[MKContextObserver contextWillEnd:^(id<MKContext> ctx)
                        {
                            XCTAssertEqual(context, ctx, @"received wrong context");
                            contextWillEnd = YES;
                        } didEnd:nil]];
    [context end];
    XCTAssertTrue(contextWillEnd, @"contextWillEnd not received");
}

- (void)testCanReceiveNotifiedWhenContextDidEnd
{
    __block BOOL contextDidEnd = NO;
    MKContext *context = [rootContext newChildContext];
    [context subscribe:[MKContextObserver contextDidEnd:^(id<MKContext> ctx)
                        {
                            XCTAssertEqual(context, ctx, @"received wrong context");
                            contextDidEnd = YES;
                        }]];
    [context end];
    XCTAssertTrue(contextDidEnd, @"contextDidEnd not received");
}

- (void)testCanReceiveNotifiedWhenChildContextWillEnd
{
    __block BOOL contextWillEnd = NO;
    MKContext *context = [rootContext newChildContext];
    [rootContext subscribe:[MKContextObserver childContextWillEnd:^(id<MKContext> ctx)
                            {
                                XCTAssertEqual(context, ctx, @"received wrong child context");
                                contextWillEnd = YES;
                            } didEnd:nil]];
    [context end];
    XCTAssertTrue(contextWillEnd, @"contextWillEnd not received");
}

- (void)testCanReceiveNotifiedWhenChildContextDidEnd
{
    __block BOOL contextDidEnd = NO;
    MKContext *context = [rootContext newChildContext];
    [rootContext subscribe:[MKContextObserver childContextDidEnd:^(id<MKContext> ctx)
                            {
                                XCTAssertEqual(context, ctx, @"received wrong child context");
                                contextDidEnd = YES;
                            }]];
    [context end];
    XCTAssertTrue(contextDidEnd, @"contextDidEnd not received");
}

- (void)testCanUnsubscribrNotificationsFromContext
{
    __block BOOL contextDidEnd = NO;
    XCTAssertFalse(contextDidEnd, @"contextDidEnd was received");
    MKContext *context = [rootContext newChildContext];
    MKContextUnsubscribe unsubscribe =
    [context subscribe:[MKContextObserver contextDidEnd:^(id<MKContext> ctx)
                        {
                            contextDidEnd = YES;
                        }]];
    unsubscribe();
    [context end];
    XCTAssertFalse(contextDidEnd, @"contextDidEnd was received");
}

- (void)testCanUnsubscribrNotificationsFromChildContext
{
    __block BOOL contextDidEnd = NO;
    XCTAssertFalse(contextDidEnd, @"contextDidEnd was received");
    MKContext *context = [rootContext newChildContext];
    MKContextUnsubscribe unsubscribe =
    [rootContext subscribe:[MKContextObserver childContextDidEnd:^(id<MKContext> ctx)
                            {
                                contextDidEnd = YES;
                            }]];
    unsubscribe();
    [context end];
    XCTAssertFalse(contextDidEnd, @"contextDidEnd was received");
}

- (void)testChildContextWillEndWhenParentEnds
{
    __block BOOL contextDidEnd = NO;
    MKContext *context = [rootContext newChildContext];
    [context subscribe:[MKContextObserver contextDidEnd:^(id<MKContext> ctx)
                        {
                            XCTAssertEqual(context, ctx, @"received wrong context");
                            contextDidEnd = YES;
                        }]];
    [rootContext end];
    XCTAssertTrue(contextDidEnd, @"child contextDidEnd not received");
}

#pragma mark - UINavigation Context tests

- (void)testUINavigationControllerWillCreateChildContextForChildren
{
    SomeViewController     *someController = [SomeViewController new];
    UINavigationController *navigation     = [[UINavigationController newInContext:rootContext]
                                              initWithRootViewController:someController];
    
    for (UIViewController<MKContextual> *controller in navigation.viewControllers)
    {
        MKContext *childContext = [controller context];
        XCTAssertNotNil(childContext, @"Child context is nil");
    }
}

- (void)testUINavigationControllerWillCreateChildContextOnPush
{
    UINavigationController *navigation     = [UINavigationController newInContext:rootContext];
    SomeViewController     *someController = [SomeViewController new];
    
    [navigation pushViewController:someController animated:NO];
    MKContext *childContext = [someController context];
    XCTAssertNotNil(childContext, @"Child context is nil");
}

- (void)testUINavigationControllerWillEndChildContextOnPop
{
    UIViewController       *rootController = [UIViewController new];
    UINavigationController *navigation     = [[UINavigationController alloc]
                                              initWithRootViewController:rootController];
    
    SomeViewController     *someController = [SomeViewController new];
    [(id)navigation         setContext:rootContext];
    
    __block BOOL childContextEnded = NO;
    [navigation pushViewController:someController animated:NO];
    MKContext *childContext = [someController context];
    [childContext subscribe:[MKContextObserver contextDidEnd:^(MKContext *ctx)
                             {
                                 if (ctx == childContext)
                                     childContextEnded = YES;
                             }] retain:YES];
    [navigation popViewControllerAnimated:NO];
    
    XCTAssertTrue(childContextEnded, @"Child context did not end");
}

- (void)testUINavigationControllerPopWhenContextEnds
{
    UIViewController       *rootController = [UIViewController new];
    UINavigationController *navigation     = [[UINavigationController alloc]
                                              initWithRootViewController:rootController];
    
    SomeViewController     *someController = [SomeViewController new];
    [(id)navigation         setContext:rootContext];
    
    [navigation pushViewController:someController animated:NO];
    XCTAssertEqual(someController, navigation.topViewController, @"SomeController should be top");
    MKContext *childContext = [someController context];
    [childContext end];
    
    XCTAssertEqual(rootController, navigation.topViewController, @"SomeController should not be top");
}

- (void)testCanAllocationAnObjectInAContext
{
    SomeContextualObject *someObject = [SomeContextualObject allocInContext:rootContext];
    XCTAssertFalse(someObject.initWasCalled, @"init should not have been called");
    XCTAssertEqual(rootContext, someObject.context, @"Contexts don't match");
}

- (void)testCanAllocationAnObjectInAChildContext
{
    SomeContextualObject *someObject = [SomeContextualObject allocInChildContext:rootContext];
    XCTAssertFalse(someObject.initWasCalled, @"init should not have been called");
    XCTAssertEqual(rootContext, someObject.context.parent, @"Parent context does not match");
}

- (void)testCanNewAnObjectInAContext
{
    SomeContextualObject *someObject = [SomeContextualObject newInContext:rootContext];
    XCTAssertTrue(someObject.initWasCalled, @"init should have been called");
    XCTAssertEqual(rootContext, someObject.context, @"Contexts don't match");
}

- (void)testCanNewAnObjectInAChildContext
{
    SomeContextualObject *someObject = [SomeContextualObject newInChildContext:rootContext];
    XCTAssertTrue(someObject.initWasCalled, @"init should have been called");
    XCTAssertEqual(rootContext, someObject.context.parent, @"Parent context does not match");
}

- (void)testCanCancelPromiseWhenContextEnds
{
    MKContext          *childContext   = [rootContext newChildContext];
    SomeViewController *someController = [SomeViewController allocInContext:childContext];
    MKDeferred         *deferred       = [(id)[someController.context trackPromise] longRunningOperation];
    
    XCTAssertNotNil(deferred, @"Deferred was nil");
    XCTAssertFalse(deferred.isCancelled, @"Deferred should not be cancelled");
    
    [childContext end];
    //XCTAssertTrue(deferred.isCancelled, @"Deferred should be cancelled");
}

- (void)testCanTraverseContextGrapthInPreOrder
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    MKContext *child2_1 = [child2 newChildContext];
    MKContext *child2_2 = [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    NSMutableArray *visited = [NSMutableArray new];
    [MKTraversal preOrder:rootContext visitor:^(id<MKTraversing> node, BOOL *stop) {
        [visited addObject:node];
    }];
    
    NSInteger index = 0;
    
    XCTAssertEqual(10U, visited.count, @"Expected 10 visited contexts");
    
    // The following assertions rely on the fact that child contexts are pushed
    
    XCTAssertEqual(rootContext, visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3,      visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3_3,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3_2,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3_1,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child2,      visited[index++], @"Not in pre-order");
    XCTAssertEqual(child2_2,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child2_1,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child1,      visited[index++], @"Not in pre-order");
    XCTAssertEqual(child1_1,    visited[index++], @"Not in pre-order");
}

- (void)testCanTraverseContextGrapthInPostOrder
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    MKContext *child2_1 = [child2 newChildContext];
    MKContext *child2_2 = [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    NSMutableArray *visited = [NSMutableArray new];
    [MKTraversal postOrder:rootContext visitor:^(id<MKTraversing> node, BOOL *stop) {
        [visited addObject:node];
    }];
    
    NSInteger index = 0;
    
    XCTAssertEqual(10U, visited.count, @"Expected 10 visited contexts");
    
    // The following assertions rely on the fact that child contexts are pushed
    
    XCTAssertEqual(child3_3,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3_2,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3_1,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child3,      visited[index++], @"Not in pre-order");
    XCTAssertEqual(child2_2,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child2_1,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child2,      visited[index++], @"Not in pre-order");
    XCTAssertEqual(child1_1,    visited[index++], @"Not in pre-order");
    XCTAssertEqual(child1,      visited[index++], @"Not in pre-order");
    XCTAssertEqual(rootContext, visited[index++], @"Not in pre-order");
}

- (void)testCanTraverseContextGrapthInLevelOrder
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    MKContext *child2_1 = [child2 newChildContext];
    MKContext *child2_2 = [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    NSMutableArray *visited = [NSMutableArray new];
    [MKTraversal levelOrder:rootContext visitor:^(id<MKTraversing> node, BOOL *stop) {
        [visited addObject:node];
    }];
    
    NSInteger index = 0;
    
    XCTAssertEqual(10U, visited.count, @"Expected 10 visited contexts");
    
    // The following assertions rely on the fact that child contexts are pushed
    
    XCTAssertEqual(rootContext, visited[index++], @"Not in level-order");
    XCTAssertEqual(child3,      visited[index++], @"Not in level-order");
    XCTAssertEqual(child2,      visited[index++], @"Not in level-order");
    XCTAssertEqual(child1,      visited[index++], @"Not in level-order");
    XCTAssertEqual(child3_3,    visited[index++], @"Not in level-order");
    XCTAssertEqual(child3_2,    visited[index++], @"Not in level-order");
    XCTAssertEqual(child3_1,    visited[index++], @"Not in level-order");
    XCTAssertEqual(child2_2,    visited[index++], @"Not in level-order");
    XCTAssertEqual(child2_1,    visited[index++], @"Not in level-order");
    XCTAssertEqual(child1_1,    visited[index++], @"Not in level-order");
}

- (void)testCanTraverseContextSelf
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    [child2 newChildContext];
    [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [rootContext traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisSelf];
    
    XCTAssertEqualObjects(@[rootContext], nodes, @"Expected only rootContext");
}

- (void)testCanTraverseContextRoot
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    [child2 newChildContext];
    [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [child3 traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisRoot];
    
    XCTAssertEqualObjects(@[rootContext], nodes, @"Expected only rootContext");
}

- (void)testCanTraverseContextChild
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    [child2 newChildContext];
    [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [rootContext traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisChild];
    
    XCTAssertTrue(([[NSSet setWithArray:@[child1, child2, child3]]
                   isEqualToSet:[NSSet setWithArray:nodes]]),
                 @"Expected toplevel children");
}

- (void)testCanTraverseContextChildOrSelf
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    [child2 newChildContext];
    [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [rootContext traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisChildOrSelf];
    
    XCTAssertTrue(([[NSSet setWithArray:@[rootContext, child1, child2, child3]]
                   isEqualToSet:[NSSet setWithArray:nodes]]),
                 @"Expected toplevel children");
}

- (void)testCanTraverseContextAncestor
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    [child1 newChildContext];
    [child1 newChildContext];
    MKContext *child1_1_1 = [child1_1 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [child1_1_1 traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisAncestor];
    
    XCTAssertTrue(([[NSSet setWithArray:@[rootContext, child1, child1_1]]
                   isEqualToSet:[NSSet setWithArray:nodes]]),
                 @"Expected all ancestors");
}

- (void)testCanTraverseContextAncestorOrSelf
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    [child1 newChildContext];
    [child1 newChildContext];
    MKContext *child1_1_1 = [child1_1 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [child1_1_1 traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisAncestorOrSelf];
    
    XCTAssertTrue(([[NSSet setWithArray:@[rootContext, child1, child1_1, child1_1_1]]
                   isEqualToSet:[NSSet setWithArray:nodes]]),
                 @"Expected all ancestors");
}

- (void)testCanTraverseContextDescendant
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    MKContext *child2_1 = [child2 newChildContext];
    MKContext *child2_2 = [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [rootContext traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisDescendant];
    
    XCTAssertTrue(([[NSSet setWithArray:@[child1, child1_1, child2, child2_1, child2_2,
                                         child3, child3_1, child3_2, child3_3]]
                   isEqualToSet:[NSSet setWithArray:nodes]]),
                 @"Expected all descendants");
}

- (void)testCanTraverseContextDescendantOrSelf
{
    MKContext *child1   = [rootContext newChildContext];
    MKContext *child1_1 = [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    MKContext *child2_1 = [child2 newChildContext];
    MKContext *child2_2 = [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    NSMutableArray *nodes = [NSMutableArray new];
    [rootContext traverse:^(id<MKTraversing> node, BOOL *stop) {
        [nodes addObject:node];
    } axis:MKTraversingAxisDescendantOrSelf];
    
    XCTAssertTrue(([[NSSet setWithArray:@[rootContext,
                                         child1, child1_1, child2, child2_1, child2_2,
                                         child3, child3_1, child3_2, child3_3]]
                   isEqualToSet:[NSSet setWithArray:nodes]]),
                 @"Expected all descendants and self");
}

- (void)testCanBroadcastToContextSelf
{
    [SomeViewController allocInContext:rootContext];
    XCTAssertEqual(8, [(id)[rootContext SELF] add:5 to:3], @"5 + 3 = 8");
    
    MKContext *childContext = [[rootContext newChildContext] bestEffort];
    XCTAssertEqual(0, [(id)[childContext SELF] add:5 to:3], @"Should not compute");
}

- (void)testCanBroadcastToContextChildren
{
    MKContext *childContext = [rootContext newChildContext];
    [SomeViewController allocInContext:childContext];
    XCTAssertEqual(30, [(id)[rootContext child] add:8 to:22], @"8 + 22 = 30");
}

- (void)testCanBroadcastToContextChildrenOrSelf
{
    [SomeViewController allocInContext:rootContext];
    XCTAssertEqual(22, [(id)[rootContext childOrSelf] add:12 to:10], @"12 + 10 = 22");
}

- (void)testCanBroadcastToContextAncestors
{
    [SomeViewController allocInContext:rootContext];
    MKContext *grandchildContext = [[rootContext newChildContext] newChildContext];
    XCTAssertEqual(38, [(id)[grandchildContext ancestor] add:9 to:29], @"9 + 29 = 38");
}

- (void)testCanBroadcastToContextDescendants
{
    MKContext *grandchildContext = [[rootContext newChildContext] newChildContext];
    [SomeViewController allocInContext:grandchildContext];
    XCTAssertEqual(53, [(id)[rootContext descendant] add:19 to:34], @"19 + 34 = 53");
}

- (void)testCanBroadcastToContextAncestorsOrSelf
{
    [SomeViewController allocInContext:rootContext];
    XCTAssertEqual(30, [(id)[rootContext ancestorOrSelf] add:1 to:29], @"1 + 29 = 30");
}

- (void)testCanBroadcastToContextDescendantsOrSelf
{
    [SomeViewController allocInContext:rootContext];
    XCTAssertEqual(20, [(id)[rootContext descendantOrSelf] add:6 to:14], @"6 + 14 = 20");
}

- (void)testCanBestEffortToContextDescendants
{
    XCTAssertEqual(0, [[(id)[rootContext descendant] bestEffort] add:19 to:34], @"Should not compute");
}

- (void)testCanNotifyContextDescendants
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    [child2 newChildContext];
    [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    [child3 newChildContext];
    [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    [SomeViewController allocInContext:child3_3];
    
    XCTAssertEqual(41, [[(id)[rootContext descendant] notify] add:22 to:19], @"22 + 19 = 41");
}

//- (void)testCanNotifyRootContextDescendants
//{
//    MKContext *child1   = [rootContext newChildContext];
//    [child1 newChildContext];
//
//    MKContext *child2   = [rootContext newChildContext];
//    [child2 newChildContext];
//    MKContext *child2_2 = [child2 newChildContext];
//    [SomeViewController allocInContext:child2_2];
//
//    MKContext *child3   = [rootContext newChildContext];
//    [child3 newChildContext];
//    [child3 newChildContext];
//    MKContext *child3_3 = [child3 newChildContext];
//
//    XCTAssertEqual(41, [[(id)[[child3_3 root] descendantOrSelf] notify] add:22 to:19], @"22 + 19 = 41");
//}

- (void)testCanCallContextMessagesOnBroadcast
{
    __block BOOL contextEnded = NO;
    
    MKContext *context = [[rootContext newChildContext] child];
    [context subscribeDidEnd:^(id<MKContext> context) {
        contextEnded = YES;
    }];
    [context end];
    
    XCTAssertTrue(contextEnded, @"context didn't end");
}

- (void)testCanObtainViewControllerAssociatedWithContext
{
    SomeViewController *contoller = [SomeViewController allocInContext:rootContext];
    
    SomeViewController *retrieved;
    XCTAssertTrue([rootContext tryGetClass:SomeViewController.class into:&retrieved],
                 @"Unable to retrieve SomeViewController");
    
    XCTAssertEqual(contoller, retrieved, @"Expected same SomeViewController");
}

- (void)testCanUnwindContext
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    [child2 newChildContext];
    [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    [child3 unwind];
    
    XCTAssertFalse(child3.state == MKContextStateEnded,  @"child3 ended");
    XCTAssertEqual(child3_1.state, MKContextStateEnded, @"child3_1 active");
    XCTAssertEqual(child3_2.state, MKContextStateEnded, @"child3_2 active");
    XCTAssertEqual(child3_3.state, MKContextStateEnded, @"child3_3 active");
}

- (void)testCanUnwindToRootContext
{
    MKContext *child1   = [rootContext newChildContext];
    [child1 newChildContext];
    
    MKContext *child2   = [rootContext newChildContext];
    MKContext *child2_1 = [child2 newChildContext];
    MKContext *child2_2 = [child2 newChildContext];
    
    MKContext *child3   = [rootContext newChildContext];
    MKContext *child3_1 = [child3 newChildContext];
    MKContext *child3_2 = [child3 newChildContext];
    MKContext *child3_3 = [child3 newChildContext];
    
    MKContext *root = [child3_3 unwindToRootContext];
    
    XCTAssertEqualObjects(rootContext, root, @"Root context mismatch");
    XCTAssertFalse(root.state == MKContextStateEnded,  @"root ended");
    XCTAssertEqual(child2.state, MKContextStateEnded, @"child2 active");
    XCTAssertEqual(child2_1.state, MKContextStateEnded, @"child2_1 active");
    XCTAssertEqual(child2_2.state, MKContextStateEnded, @"child2_2 active");
    XCTAssertEqual(child3.state, MKContextStateEnded, @"child3 active");
    XCTAssertEqual(child3_1.state, MKContextStateEnded, @"child3_1 active");
    XCTAssertEqual(child3_2.state, MKContextStateEnded, @"child3_2 active");
    XCTAssertEqual(child3_3.state, MKContextStateEnded, @"child3_3 active");
}

@end
