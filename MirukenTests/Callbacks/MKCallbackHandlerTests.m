//
//  MKCallbackHandlerTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MirukenCallbacks.h"
#import "Configuration.h"
#import "ResourceUsage.h"
#import "GetResource.h"
#import "ApplicationCallbackHandler.h"
#import "ConfigurationCallbackHandler.h"
#import "ConfigurationTagCallbackHandler.h"
#import "ResourcesCallbackHandler.h"

@interface MKCallbackHandlerTests : XCTestCase
{
    NSDictionary *properties;
}

@end

@implementation MKCallbackHandlerTests

- (void)setUp
{
    [super setUp];
    
    properties = @{@"FirstName" : @"Craig",
                   @"LastName"  : @"Neuwirt",
                   @"Hobby"     : @"Soccer"};
}

- (void)tearDown
{
    properties = nil;
    
    [super tearDown];
}

- (void)testCanHandleCallbackClass
{
    
    NSDictionary      *item;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    BOOL               handled = [handler tryGetClass:NSDictionary.class into:&item];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqual(item, properties, @"The callback does not match");
}

- (void)testCanHandleCallbackClassUsingSubscripting
{
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    NSDictionary      *item    = handler[NSDictionary.class];
    XCTAssertEqual(item, properties, @"The callback does not match");
}

- (void)testWillInformIfCallbackNotHandled
{
    
    NSDictionary      *item;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    BOOL               handled = [handler tryGetClass:NSString.class into:&item];
    XCTAssertFalse(handled, @"The callback was handled");
}

- (void)testCanConsumeCallbackClass
{
    BOOL __block       handled = NO;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    [[handler getClassDeferred:NSDictionary.class] done:^(NSDictionary *item) {
        XCTAssertEqual(item, properties, @"The callback does not match");
        XCTAssertEqualObjects(@"Craig", [item objectForKey:@"FirstName"], @"values don't match");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testCanFailConsumeCallbackClass
{
    BOOL __block       handled = YES;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    [[handler getClassDeferred:NSArray.class] error:^(NSError *error, BOOL *h) {
        XCTAssertEqualObjects(error.domain, MKCallbackErrorDomain, @"Incorrect error domain");
        XCTAssertEqual(error.code, MKCallbackErrorCallbackClassNotFound, @"Incorrect error code");
        handled = NO;
    }];
    XCTAssertFalse(handled, @"The callback class was handled");
}

- (void)testCanHandleCallbackProtocol
{
    NSDictionary      *item;
    MKCallbackHandler *handler = [properties toCallbackHandler];
    BOOL               handled = [handler tryGetProtocol:@protocol(NSFastEnumeration) into:&item];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqual(item, properties, @"The callback does not match");
}

- (void)testCanHandleCallbackProtocolUsingSubscripting
{
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    NSDictionary      *item    = handler[@protocol(NSFastEnumeration)];
    XCTAssertEqual(item, properties, @"The callback does not match");
}

- (void)testRejectHandlerCallbackSubscriptingIfNotClassOrProtocol
{
    id ignore;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    XCTAssertThrows(ignore = handler[@"Hello"], @"Expected unrecognized index");
}

- (void)testCanConsumeCallbackProtocol
{
    BOOL __block       handled = NO;
    MKCallbackHandler *handler = [properties toCallbackHandler];
    [[handler getProtocolDeferred:@protocol(NSFastEnumeration)] done:^(id<NSFastEnumeration> item) {
        XCTAssertEqual(item, properties, @"The callback does not match");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testCanFailConsumeCallbackProtocol
{
    BOOL __block       handled = YES;
    MKCallbackHandler *handler = [properties toCallbackHandler];
    [[handler getProtocolDeferred:@protocol(MKCallbackHandler)] error:^(NSError *error, BOOL *h) {
        XCTAssertEqualObjects(error.domain, MKCallbackErrorDomain, @"Incorrect error domain");
        XCTAssertEqual(error.code, MKCallbackErrorCallbackProtocolNotFound, @"Incorrect error code");
        handled = NO;
    }];
    XCTAssertFalse(handled, @"The callback protocol was handled");
}

- (void)testCanHandleCallbackInCustomHandler
{
    Configuration                *config  = [Configuration new];
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    BOOL                          handled = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanProvideCallbackClassInCustomHandler
{
    Configuration                *config;
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    BOOL                          handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanProvideCallbackToSelfIfDynamicHandler
{
    ConfigurationCallbackHandler *h;
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    BOOL                          handled = [handler tryGetClass:ConfigurationCallbackHandler.class into:&h];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqual(handler, h, @"The handlers should be same");
}

- (void)testCanProvideCallbackProtocolInCustomHandler
{
    Configuration                *config;
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    BOOL                          handled = [handler tryGetProtocol:@protocol(Configuration) into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanConsumeCallbackInCustomHandler
{
    BOOL __block                  handled = NO;
    Configuration                *config  = [Configuration new];
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    [[handler handleDeferred:config] done:^(Configuration *theConfig) {
        XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testCanFailConsumeCallbackInCustomHandler
{
    BOOL __block                  handled = YES;
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    [[handler handleDeferred:[NSArray new]] error:^(NSError *error, BOOL *h) {
        XCTAssertEqualObjects(error.domain, MKCallbackErrorDomain, @"Incorrect error domain");
        XCTAssertEqual(error.code, MKCallbackErrorCallbackNotHandled, @"Incorrect error code");
        handled = NO;
    }];
    XCTAssertFalse(handled, @"The callback was not handled");
}

- (void)testCanCascadeCallbackHandlers
{
    MKCallbackHandler            *handler1 = [properties toCallbackHandler:YES];
    Configuration                *config   = [Configuration new];
    ConfigurationCallbackHandler *handler2 = [ConfigurationCallbackHandler new];
    MKCallbackHandler            *handler  = [handler1 then:handler2];
    BOOL                          handled  = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanComposeMultiplHandlers
{
    Configuration              *config  = [Configuration new];
    MKCompositeCallbackHandler *handler = [MKCompositeCallbackHandler withHandlers:
                                           [ConfigurationCallbackHandler new],
                                           [ConfigurationTagCallbackHandler new], nil];
    BOOL                        handled = [handler handle:config greedy:YES];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertTrue([config.tags containsObject:@"primary"],   @"The tag 'primary' was not found");
    XCTAssertTrue([config.tags containsObject:@"secondary"], @"The tag 'secondary' was not found");
}

- (void)testCanComposeMultiplHandlersImmutably
{
    Configuration     *config  = [Configuration new];
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  thenAll:[ConfigurationTagCallbackHandler new],
                                  [properties toCallbackHandler],
                                 nil];
    BOOL             handled  = [handler handle:config greedy:YES];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertTrue([config.tags containsObject:@"primary"],   @"The tag 'primary' was not found");
    XCTAssertTrue([config.tags containsObject:@"secondary"], @"The tag 'secondary' was not found");
}

- (void)testCanAcceptClassCallbacksOnDemand
{
    Configuration     *config  = [Configuration new];
    MKCallbackHandler *handler =
    [MKCallbackHandler acceptingClass:Configuration.class
                               handle:^(Configuration *theConfig, MKCallbackHandler *composer)
     {
         theConfig.url = @"www.rise.com";
         return YES;
     }];
    BOOL             handled  = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.rise.com", @"expected url www.rise.com");
}

- (void)testCanInsertHandlerAtIndex
{
    Configuration                   *config     = [Configuration new];
    ConfigurationTagCallbackHandler *tagHandler = [ConfigurationTagCallbackHandler new];
    MKCompositeCallbackHandler      *handler    = [MKCompositeCallbackHandler withHandler:
                                                    [ConfigurationCallbackHandler new]];
    [handler insertHandler:tagHandler atIndex:0];
    BOOL                             handled    = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertFalse([config.tags containsObject:@"primary"],   @"The tag 'primary' was found");
    XCTAssertTrue([config.tags containsObject:@"secondary"], @"The tag 'secondary' was not found");
}

- (void)testCanInsertHandlerAfterClass
{
    Configuration                   *config     = [Configuration new];
    ConfigurationTagCallbackHandler *tagHandler = [ConfigurationTagCallbackHandler new];
    MKCompositeCallbackHandler      *handler    = [MKCompositeCallbackHandler withHandler:
                                                    [ConfigurationCallbackHandler new]];
    [handler insertHandler:tagHandler afterClass:ConfigurationCallbackHandler.class];
    BOOL                             handled    = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertTrue ([config.tags containsObject:@"primary"],   @"The tag 'primary' was not found");
    XCTAssertFalse([config.tags containsObject:@"secondary"], @"The tag 'secondary' was found");
}

- (void)testCanInsertHandlerBeforeClass
{
    Configuration                   *config     = [Configuration new];
    ConfigurationTagCallbackHandler *tagHandler = [ConfigurationTagCallbackHandler new];
    MKCompositeCallbackHandler      *handler    = [MKCompositeCallbackHandler withHandler:
                                                    [ConfigurationCallbackHandler new]];
    [handler insertHandler:tagHandler beforeClass:ConfigurationCallbackHandler.class];
    BOOL                             handled    = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertFalse([config.tags containsObject:@"primary"],   @"The tag 'primary' was found");
    XCTAssertTrue([config.tags containsObject:@"secondary"], @"The tag 'secondary' was not found");
}

- (void)testCanReplaceHandler
{
    Configuration                   *config     = [Configuration new];
    ConfigurationTagCallbackHandler *tagHandler = [ConfigurationTagCallbackHandler new];
    MKCompositeCallbackHandler      *handler    = [MKCompositeCallbackHandler withHandler:
                                                    [ConfigurationCallbackHandler new]];
    [handler replaceHandler:tagHandler forClass:ConfigurationCallbackHandler.class];
    BOOL                             handled    = [handler handle:config greedy:YES];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertFalse([config.tags containsObject:@"primary"],   @"The tag 'primary' was found");
    XCTAssertTrue([config.tags containsObject:@"secondary"], @"The tag 'secondary' was not found");
}

- (void)testCanAcceptClassCallbacksOnDemandShortcut
{
    Configuration     *config  = [Configuration new];
    MKCallbackHandler *handler = [Configuration
                                  accept:^(Configuration *theConfig, MKCallbackHandler *composer)
                                  {
                                      theConfig.url = @"www.rise.com";
                                      return YES;
                                  }];
    BOOL              handled  = [handler handle:config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.rise.com", @"expected url www.rise.com");
}

- (void)testCanAcceptProtocolCallbacksOnDemand
{
    __block NSDictionary  *dict;
    MKCallbackHandler     *handler =
    [MKCallbackHandler acceptingProtocol:@protocol(NSFastEnumeration)
                                  handle:^(id <NSFastEnumeration> fe, MKCallbackHandler *composer)
     {
         dict = properties;
         return YES;
     }];
    BOOL                  handled  = [handler handle:properties];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqual(properties, dict, @"expected same dictionary");
}

- (void)testCanProvideClassCallbacksOnDemand
{
    MKCallbackHandler  *handler =
    [MKCallbackHandler providingClass:Configuration.class handle:^(MKCallbackHandler *composer)
    {
        Configuration *config = [Configuration new];
        config.url            = @"www.rise.com";
        return config;
        }];
    Configuration      *config;
    BOOL                handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.rise.com", @"expected url www.rise.com");
}

- (void)testCanProvideClassCallbacksOnDemandShortcut
{
    MKCallbackHandler  *handler = [Configuration provide:^(MKCallbackHandler *composer)
                                   {
                                       Configuration *config = [Configuration new];
                                       config.url            = @"www.rise.com";
                                       return config;
                                   }];
    Configuration      *config;
    BOOL                handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.rise.com", @"expected url www.rise.com");
}

- (void)testCanProvideProtocolCallbacksOnDemand
{
    MKCallbackHandler *handler =
    [MKCallbackHandler providingProtocol:@protocol(NSFastEnumeration) handle:^(MKCallbackHandler *composer)
     {
         return properties;
     }];
    id<NSFastEnumeration> fastEnumerator;
    BOOL                  handled = [handler tryGetProtocol:@protocol(NSFastEnumeration) into:&fastEnumerator];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertEqual(properties, fastEnumerator, @"expected same dictionary");
}

- (void)testCanGreedilyHandleCallbacks
{
    Configuration                   *config   = [Configuration new];
    ConfigurationCallbackHandler    *handler1 = [ConfigurationCallbackHandler new];
    ConfigurationTagCallbackHandler *handler2 = [ConfigurationTagCallbackHandler new];
    MKCallbackHandler               *handler  = [handler1 then:handler2];
    BOOL                             handled  = [handler handle:config greedy:YES];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertTrue([config.tags containsObject:@"primary"],   @"The tag 'primary' was not found");
    XCTAssertTrue([config.tags containsObject:@"secondary"], @"The tag 'secondary' was not found");
}

- (void)testCanFilterCallbackWithCondition
{
    id<MKCallbackHandler>  handler = [[ConfigurationCallbackHandler new]
                                      when:^(Configuration *config)
                                      {
                                          return (BOOL)(config.tags.count > 0);
                                      }];
    
    Configuration         *config  = [Configuration new];
    BOOL                   handled = [handler handle:config greedy:YES];
    XCTAssertFalse(handled, @"The callback was handled");
}

- (void)testCanFilterCallbackWithPredicate
{
    Configuration     *config  = [[Configuration alloc] initWithName:@"MyConfig"];
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new] whenPredicate:
                                  [NSPredicate predicateWithFormat:@"name = 'MyConfig'"]];
    BOOL               handled = [handler handle:config greedy:YES];
    XCTAssertTrue(handled, @"The callback was not handled");
    XCTAssertTrue([config.tags containsObject:@"primary"],   @"The tag 'primary' was not found");
}

- (void)testCanRejectCallbackWithPredicate
{
    Configuration     *config  = [[Configuration alloc] initWithName:@"MyConfig"];
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new] whenPredicate:
                                  [NSPredicate predicateWithFormat:@"name = 'AnotherConfig'"]];
    BOOL               handled = [handler handle:config greedy:YES];
    XCTAssertFalse(handled, @"The callback was handled");
}

- (void)testCanFilterCallbackKindOfClass
{
    Configuration     *config;
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenKindOfClass:Configuration.class];
    BOOL               handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testWillSkipCallbackNotKindOfClass
{
    Configuration     *config;
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenKindOfClass:NSDictionary.class];
    BOOL               handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertFalse(handled, @"The callback was handled");
}

- (void)testCanFilterCallbackConformingToProtocol
{
    Configuration     *config;
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenConformsToProtocol:@protocol(Configuration)];
    BOOL               handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testWillSkipCallbackNotConformingToProtocol
{
    Configuration     *config;
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenConformsToProtocol:@protocol(NSFastEnumeration)];
    BOOL               handled = [handler tryGetClass:Configuration.class into:&config];
    XCTAssertFalse(handled, @"The callback was handled");
}

- (void)testCanDelegateDynamicCallbackHandler
{
    Configuration            *config  = [Configuration new];
    MKDynamicCallbackHandler *handler = [MKDynamicCallbackHandler delegateTo:self];
    BOOL                      handled = [handler handle:config];
    XCTAssertTrue(handled, @"The configuration was not handled");
}

- (void)testHandlerComposition
{
    MKCompositeCallbackHandler *handlers = [MKCompositeCallbackHandler
                                            withHandlers:[ConfigurationCallbackHandler new],
                                            [ConfigurationTagCallbackHandler new],
                                            [ResourcesCallbackHandler new],
                                            nil];
    
    GetResource  *getResource = [GetResource withId:@"1234"];
    BOOL          handled     = [handlers handle:getResource];
    XCTAssertTrue(handled, @"The resource was not handled");
    NSDictionary *resource    = (NSDictionary *)getResource.resource;
    XCTAssertEqualObjects([resource valueForKey:@"url"], @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanProviderCallbackInDynamicCallbackHandlerWithComposition
{
    ResourceUsage            *stats;
    ResourcesCallbackHandler *handler = [ResourcesCallbackHandler new];
    BOOL                      handled = [handler tryGetClass:ResourceUsage.class into:&stats];
    XCTAssertTrue(handled, @"The resource stats was not handled");
    XCTAssertNotNil(stats, @"stats was nil");
}

- (void)testCanHandleMethodOnCallbackHandler
{
    ApplicationCallbackHandler *handler = [ApplicationCallbackHandler new];
    BOOL launch = [(id<UIApplicationDelegate>)handler application:[UIApplication sharedApplication]
                                    didFinishLaunchingWithOptions:@{ @"Settings" : @"MySettings.plist" }];
    
    XCTAssertTrue(launch, @"launch not true");
    NSDictionary *launchOptions = handler.launchOptions;
    XCTAssertNotNil(launchOptions, @"launchOptions are nil");
    XCTAssertEqualObjects([launchOptions valueForKey:@"Settings"], @"MySettings.plist",
                          @"Settings don't match");
}

- (void)testWillFailIfMethodOnCallbackHandlerNotRecognized
{
    ApplicationCallbackHandler *handler = [ApplicationCallbackHandler new];
    XCTAssertThrows([(id)handler removeObject:nil], @"Expected unrecognized selector");
}

- (void)testBestEffortWillIgnoreMethodOnCallbackHandlerNotRecognized
{
    ApplicationCallbackHandler *handler = [[ApplicationCallbackHandler new] bestEffort];
    [(id)handler removeObject:nil];
}

- (void)testWillFailIfMethodOnCallbackHandlerRecognizedButNotHandled
{
    ApplicationCallbackHandler *handler = [ApplicationCallbackHandler new];
    XCTAssertThrows([(id<UIApplicationDelegate>)handler applicationDidBecomeActive:[UIApplication sharedApplication]], @"Expected unrecognized selector");
}

- (void)testBestEffortWillIgnoreMethodOnCallbackHandlerRecognizedButNotHandled
{
    ApplicationCallbackHandler *handler = [[ApplicationCallbackHandler new] bestEffort];
    [(id<UIApplicationDelegate>)handler applicationDidBecomeActive:[UIApplication sharedApplication]];
}

- (void)testWillFailBroadcastIfCallbackHandlerRecognizedButNotHandled
{
    ApplicationCallbackHandler *handler = [[ApplicationCallbackHandler new] broadcast];
    XCTAssertThrows([(id<UIApplicationDelegate>)handler applicationDidBecomeActive:[UIApplication sharedApplication]], @"Expected unrecognized selector");
}

- (void)testCanHandleMethodOnCallbackHandlerWithResult
{
    __block BOOL allow = NO;
    ApplicationCallbackHandler *handler = [ApplicationCallbackHandler new];
    BOOL launch =
    [(id<UIApplicationDelegate>)[handler withCallInvokeBlock:^(NSInvocation *invocation)
                                 {
                                     [invocation getReturnValue:&allow];
                                 }]
     application:[UIApplication sharedApplication]
     didFinishLaunchingWithOptions:@{ @"Settings" : @"MySettings.plist" }];
    
    NSDictionary *launchOptions = handler.launchOptions;
    XCTAssertNotNil(launchOptions, @"launchOptions are nil");
    XCTAssertEqualObjects([launchOptions valueForKey:@"Settings"], @"MySettings.plist", @"Settings don't match");
    XCTAssertTrue(launch == allow, @"launch and allow should be the same");
}

- (void)testCanHandleUnknownCallback
{
    NSValue                  *value   = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    MKDynamicCallbackHandler *handler = [MKDynamicCallbackHandler delegateTo:self];
    BOOL                      handled = [handler handle:value];
    XCTAssertTrue(handled, @"The value was not handled");
}

- (BOOL)handleConfiguration:(Configuration *)config
{
    config.url = @"www.fifa.com";
    XCTAssertEqualObjects(@"www.fifa.com", config.url, @"expected url www.fifa.com");
    return YES;
}

- (BOOL)handleUnknownCallback:(id)callback
{
    return YES;
}

@end
