//
//  MKTraversingTests.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKTraversingMixin.h"

#pragma mark - Animal

@interface Animal : MKTraversing

@property (strong, nonatomic) Animal  *parent;
@property (strong, nonatomic) NSArray *children;

@end

@implementation Animal
@end

#pragma mark - Shape

@interface Shape : MKTraversing

@property (strong, nonatomic) NSArray *children;

@end

@implementation Shape
@end

#pragma mark - Company

@interface Company : MKTraversing

@property (strong, nonatomic) Company *parent;

@end

@implementation Company
@end

#pragma mark - MKTraversingTests

@interface MKTraversingTests : XCTestCase

@end

@implementation MKTraversingTests

- (void)testCanTraverseAxisSelf
{
    Animal         *animal  = [Animal new];
    NSMutableArray *visited = [NSMutableArray new];
    [animal traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisSelf];
    
    XCTAssertEqualObjects(@[animal], visited, @"Expected animal");
}

- (void)testCanTraverseAxisRoot
{
    Animal         *animal  = [Animal new];
    animal.children         = @[ [Animal new], [Animal new]];
    NSMutableArray *visited = [NSMutableArray new];
    [animal traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisRoot];
    
    XCTAssertEqualObjects(@[animal], visited, @"Expected root");
}

- (void)testCanTraverseAxisChild
{
    Animal         *animal  = [Animal new];
    animal.children         = @[ [Animal new], [Animal new]];
    NSMutableArray *visited = [NSMutableArray new];
    [animal traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisChild];
    
    XCTAssertEqualObjects(animal.children, visited, @"Expected children");
}

- (void)testCanTraverseAxisChildOrSelf
{
    Animal         *animal  = [Animal new];
    Animal         *child1  = [Animal new];
    Animal         *child2  = [Animal new];
    animal.children         = @[ child1, child2 ];
    NSMutableArray *visited = [NSMutableArray new];
    [animal traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisChildOrSelf];
    
    XCTAssertEqualObjects((@[animal, child1, child2]), visited, @"Expected children");
}

- (void)testCanTraverseAxisAncestor
{
    Animal         *animal     = [Animal new];
    Animal         *child      = [Animal new];
    child.parent               = animal;
    Animal         *grandChild = [Animal new];
    grandChild.parent          = child;
    animal.children            = @[ child ];
    child.children             = @[ grandChild ];
    NSMutableArray *visited = [NSMutableArray new];
    [grandChild traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisAncestor];
    
    XCTAssertEqualObjects((@[child, animal]), visited, @"Expected ancestors");
}

- (void)testCanTraverseAxisAncestorOrSelf
{
    Animal         *animal     = [Animal new];
    Animal         *child      = [Animal new];
    child.parent               = animal;
    Animal         *grandChild = [Animal new];
    grandChild.parent          = child;
    animal.children            = @[ child ];
    child.children             = @[ grandChild ];
    NSMutableArray *visited = [NSMutableArray new];
    [grandChild traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisAncestorOrSelf];
    
    XCTAssertEqualObjects((@[grandChild, child, animal]), visited, @"Expected ancestors");
}

- (void)testCanTraverseAxisDescendant
{
    Animal         *animal     = [Animal new];
    Animal         *child      = [Animal new];
    child.parent               = animal;
    Animal         *grandChild = [Animal new];
    grandChild.parent          = child;
    animal.children            = @[ child ];
    child.children             = @[ grandChild ];
    NSMutableArray *visited = [NSMutableArray new];
    [animal traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisDescendant];
    
    XCTAssertEqualObjects((@[child, grandChild]), visited, @"Expected descendant");
}

- (void)testCanTraverseAxisDescendantOrSelf
{
    Animal         *animal     = [Animal new];
    Animal         *child      = [Animal new];
    child.parent               = animal;
    Animal         *grandChild = [Animal new];
    grandChild.parent          = child;
    animal.children            = @[ child ];
    child.children             = @[ grandChild ];
    NSMutableArray *visited = [NSMutableArray new];
    [animal traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisDescendantOrSelf];
    
    XCTAssertEqualObjects((@[animal, child, grandChild]), visited, @"Expected descendant");
}

- (void)testCanTraverseAxisParentSiblingOrSelf
{
    Animal         *animal     = [Animal new];
    Animal         *child1     = [Animal new];
    Animal         *child2     = [Animal new];
    child1.parent              = animal;
    child2.parent              = animal;
    Animal         *grandChild = [Animal new];
    grandChild.parent          = child1;
    animal.children            = @[ child1, child2 ];
    child1.children            = @[ grandChild ];
    NSMutableArray *visited = [NSMutableArray new];
    [child2 traverse:^(Animal *visit, BOOL *stop) {
        [visited addObject:visit];
    } axis:MKTraversingAxisParentSiblingOrSelf];
    
    XCTAssertEqualObjects((@[child2, child1, animal]), visited, @"Expected siblings and parent");
}

- (void)testCanRejectTraverseAxisRoot
{
    Shape *shape = [Shape new];
    XCTAssertFalse([shape canTraverseAxis:MKTraversingAxisRoot], @"Should not traverse root");
}

- (void)testWillRejectTraverseAxisRoot
{
    Shape *shape = [Shape new];
    XCTAssertThrowsSpecificNamed([shape traverse:nil axis:MKTraversingAxisRoot], NSException,
                                 NSInternalInconsistencyException, @"Should not traverse root");
}

- (void)testCanRejectTraverseAxisChild
{
    Company *company = [Company new];
    XCTAssertFalse([company canTraverseAxis:MKTraversingAxisChild], @"Should not traverse child");
}

- (void)testWillRejectTraverseAxisChild
{
    Company *company = [Company new];
    XCTAssertThrowsSpecificNamed([company traverse:nil axis:MKTraversingAxisChild],
                                 NSException, NSInternalInconsistencyException,
                                 @"Should not traverse child");
}

- (void)testCanRejectTraverseAxisAncestor
{
    Shape *company = [Shape new];
    XCTAssertFalse([company canTraverseAxis:MKTraversingAxisAncestor],
                   @"Should not traverse ancestor");
}

- (void)testWillRejectTraverseAxisAncestor
{
    Shape *shape = [Shape new];
    XCTAssertThrowsSpecificNamed([shape traverse:nil axis:MKTraversingAxisAncestor],
                                 NSException, NSInternalInconsistencyException,
                                 @"Should not traverse anecstor");
}

- (void)testCanRejectTraverseAxisDescendant
{
    Company *company = [Company new];
    XCTAssertFalse([company canTraverseAxis:MKTraversingAxisDescendant],
                   @"Should not traverse descendant");
}

- (void)testWillRejectTraverseAxisDescendant
{
    Company *company = [Company new];
    XCTAssertThrowsSpecificNamed([company traverse:nil axis:MKTraversingAxisDescendant],
                                 NSException, NSInternalInconsistencyException,
                                 @"Should not traverse descendant");
}

- (void)testCanRejectTraverseAxisParentSiblingOrSelfNoParent
{
    Shape *shape = [Shape new];
    XCTAssertFalse([shape canTraverseAxis:MKTraversingAxisParentSiblingOrSelf],
                   @"Should not traverse parent/descendant/self");
}

- (void)testWillRejectTraverseAxisParentSiblingOrSelfNoParent
{
    Shape *shape = [Shape new];
    XCTAssertThrowsSpecificNamed([shape traverse:nil axis:MKTraversingAxisParentSiblingOrSelf],
                                 NSException, NSInternalInconsistencyException,
                                 @"Should not traverse parent/descendant/self");
}

- (void)testCanRejectTraverseAxisParentSiblingOrSelfNoChildren
{
    Company *company = [Company new];
    XCTAssertFalse([company canTraverseAxis:MKTraversingAxisParentSiblingOrSelf],
                   @"Should not traverse parent/descendant/self");
}

- (void)testWillRejectTraverseAxisParentSiblingOrSelfNoChildren
{
    Company *company = [Company new];
    XCTAssertThrowsSpecificNamed([company traverse:nil axis:MKTraversingAxisParentSiblingOrSelf],
                                 NSException, NSInternalInconsistencyException,
                                 @"Should not traverse parent/descendant/self");
}

@end
