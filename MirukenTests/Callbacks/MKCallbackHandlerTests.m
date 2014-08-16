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
#import "MKDeferred.h"

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
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    NSDictionary      *item    = [handler resolve:NSDictionary.class];
    XCTAssertNotNil(item, @"The callback was not handled");
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
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    NSDictionary    *item     = [handler resolve:NSString.class];
    XCTAssertNil(item, @"The callback was handled");
}

- (void)testCanConsumeCallbackClass
{
    BOOL __block       handled = NO;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    [[[MKDeferred when:[handler resolve:NSDictionary.class]] done:^(NSDictionary *item) {
        XCTAssertEqual(item, properties, @"The callback does not match");
        XCTAssertEqualObjects(@"Craig", [item objectForKey:@"FirstName"], @"values don't match");
        handled = YES;
    }] wait];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testCanFailConsumeCallbackClass
{
    BOOL __block       handled = YES;
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
   [[[MKDeferred when:[handler resolve:NSArray.class]] done:^(NSArray *array) {
       XCTAssertNil(array, @"callback was handled");
       handled = NO;
    }] wait];
    XCTAssertFalse(handled, @"The callback class was handled");
}

- (void)testCanHandleCallbackProtocol
{
    MKCallbackHandler *handler = [properties toCallbackHandler];
    NSDictionary      *item    = [handler resolve:@protocol(NSFastEnumeration)];
    XCTAssertNotNil(item, @"The callback was not handled");
    XCTAssertEqual(item, properties, @"The callback does not match");
}

- (void)testCanHandleCallbackProtocolUsingSubscripting
{
    MKCallbackHandler *handler = [properties toCallbackHandler:YES];
    NSDictionary      *item    = handler[@protocol(NSFastEnumeration)];
    XCTAssertEqual(item, properties, @"The callback does not match");
}

- (void)testCanConsumeCallbackProtocol
{
    BOOL __block       handled = NO;
    MKCallbackHandler *handler = [properties toCallbackHandler];
    [[MKDeferred when:[handler resolve:@protocol(NSFastEnumeration)]] done:^(id<NSFastEnumeration> item) {
        XCTAssertEqual(item, properties, @"The callback does not match");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testCanFailConsumeCallbackProtocol
{
    BOOL __block       handled = NO;
    MKCallbackHandler *handler = [properties toCallbackHandler];
    [[MKDeferred when:[handler resolve:@protocol(MKCallbackHandler)]] done:^(id<MKCallbackHandler> cb) {
        XCTAssertNil(cb, @"Protocol was provided");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback protocol was handled");
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
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    Configuration                *config  = [handler resolve:Configuration.class];
    XCTAssertNotNil(config, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanProvideCallbackToSelfIfDynamicHandler
{
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    ConfigurationCallbackHandler *h       = [handler resolve:ConfigurationCallbackHandler.class];
    XCTAssertNotNil(h, @"The callback was not handled");
    XCTAssertEqual(handler, h, @"The handlers should be same");
}

- (void)testCanProvideCallbackProtocolInCustomHandler
{
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    Configuration                *config  = [handler resolve:@protocol(Configuration)];
    XCTAssertNotNil(config, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
}

- (void)testCanConsumeCallbackInCustomHandler
{
    BOOL __block                  handled = NO;
    Configuration                *config  = [Configuration new];
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    [[MKDeferred when:[handler resolve:config]] done:^(Configuration *theConfig) {
        XCTAssertEqualObjects(config.url, @"mail.google.com", @"expected url mail.google.com");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback was not handled");
}

- (void)testCanFailConsumeCallbackInCustomHandler
{
    BOOL __block                  handled = NO;
    ConfigurationCallbackHandler *handler = [ConfigurationCallbackHandler new];
    [[MKDeferred when:[handler resolve:[NSArray new]]] done:^(NSArray *array) {
        XCTAssertNil(array, @"Callback was handled");
        handled = YES;
    }];
    XCTAssertTrue(handled, @"The callback was not handled");
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
    Configuration *config = [handler resolve:Configuration.class];
    XCTAssertNotNil(config, @"The callback was not handled");
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
    Configuration *config = [handler resolve:Configuration.class];
    XCTAssertNotNil(config, @"The callback was not handled");
    XCTAssertEqualObjects(config.url, @"www.rise.com", @"expected url www.rise.com");
}

- (void)testCanProvideProtocolCallbacksOnDemand
{
    MKCallbackHandler *handler =
    [MKCallbackHandler providingProtocol:@protocol(NSFastEnumeration) handle:^(MKCallbackHandler *composer)
     {
         return properties;
     }];
    id<NSFastEnumeration> fastEnumerator = [handler resolve:@protocol(NSFastEnumeration)];
    XCTAssertNotNil(fastEnumerator, @"The callback was not handled");
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
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenKindOfClass:Configuration.class];
    Configuration     *config  = [handler resolve:Configuration.class];
    XCTAssertNotNil(config, @"The callback was not handled");
}

- (void)testWillSkipCallbackNotKindOfClass
{
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenKindOfClass:NSDictionary.class];
    Configuration     *config  = [handler resolve:Configuration.class];
    XCTAssertNil(config, @"The callback was handled");
}

- (void)testCanFilterCallbackConformingToProtocol
{
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenConformsToProtocol:@protocol(Configuration)];
    Configuration     *config  = [handler resolve:Configuration.class];
    XCTAssertNotNil(config, @"The callback was not handled");
}

- (void)testWillSkipCallbackNotConformingToProtocol
{
    MKCallbackHandler *handler = [[ConfigurationCallbackHandler new]
                                  whenConformsToProtocol:@protocol(NSFastEnumeration)];
    Configuration     *config  = [handler resolve:Configuration.class];
    XCTAssertNil(config, @"The callback was handled");
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
    ResourcesCallbackHandler *handler = [ResourcesCallbackHandler new];
    ResourceUsage            *usage   = [handler resolve:ResourceUsage.class];
    XCTAssertNotNil(usage, @"usage was nil");
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
    XCTAssertThrows([(id<UIApplicationDelegate>)handler applicationWillResignActive:[UIApplication sharedApplication]], @"Expected unrecognized selector");
}

- (void)testBestEffortWillIgnoreMethodOnCallbackHandlerRecognizedButNotHandled
{
    ApplicationCallbackHandler *handler = [[ApplicationCallbackHandler new] bestEffort];
    [(id<UIApplicationDelegate>)handler applicationDidBecomeActive:[UIApplication sharedApplication]];
}

- (void)testWillFailBroadcastIfCallbackHandlerRecognizedButNotHandled
{
    ApplicationCallbackHandler *handler = [[ApplicationCallbackHandler new] broadcast];
    XCTAssertThrows([(id<UIApplicationDelegate>)handler applicationWillResignActive:[UIApplication sharedApplication]], @"Expected unrecognized selector");
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

- (void)testWillNotPropogateGreedyThroughComposer
{
    ConfigurationCallbackHandler    *ch       = [ConfigurationCallbackHandler new];
    ConfigurationTagCallbackHandler *cth      = [ConfigurationTagCallbackHandler new];
    ResourcesCallbackHandler        *rh       = [ResourcesCallbackHandler new];
    ApplicationCallbackHandler      *ah       = [ApplicationCallbackHandler new];
    MKCompositeCallbackHandler      *handlers = [MKCompositeCallbackHandler withHandlers:
                                                 ch, cth, rh, ah, nil];
    
    BOOL started = [(id<ApplicationCallbackHandler>)[handlers notify] startMissleLaunch];
    XCTAssertTrue(started, @"Missle launch not started");
    XCTAssertTrue(ch.active, @"ConfigurationCallbackHandler should be active");
    XCTAssertFalse(cth.active, @"ConfigurationTagCallbackHandler should not be active");
    XCTAssertFalse(rh.active, @"ResourcesCallbackHandler should not be active");
    XCTAssertFalse(ah.active, @"ApplicationCallbackHandler should not be active");
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
