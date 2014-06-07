//
//  SKTreeTest.m
//  SKMech
//
//  Created by Adrian Cooney on 04/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../Classes/Library/Trees/SKTree.h"
#import "../Classes/Library/Trees/SKTreeBinary.h"

@interface SKTreeTest : XCTestCase

@end

@implementation SKTreeTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTree
{
    SKTreeNode *root = [[SKTreeNode alloc] initWithData:@"R"];
    SKTreeNode *n1 = [[SKTreeNode alloc] initWithData:@"1"];
    SKTreeNode *n2 = [[SKTreeNode alloc] initWithData:@"2"];
    SKTreeNode *n3 = [[SKTreeNode alloc] initWithData:@"3"];
    SKTreeNode *n4 = [[SKTreeNode alloc] initWithData:@"4"];
    SKTreeNode *n5 = [[SKTreeNode alloc] initWithData:@"5"];
    
    [root addChild:n1];
    [root addChild:n2];
    [n1 addChild:n3];
    [n2 addChild:n4];
    [n3 addChild:n5];
    
    __block NSUInteger i = 0;
    NSArray *depthFirst = @[@"R", @"1", @"3", @"5", @"2", @"4"];
    NSArray *depthLast = @[@"R", @"2", @"4", @"1", @"3", @"5"];
    
    SKTree *tree = [[SKTree alloc] initWithRoot:root];
    [tree traverseTreeWithOption:SKTreeTraversalDepthFirst usingBlock:^(id data, SKTreeNode *node) {
        if(![depthFirst[i] isEqualToString:(NSString *)data]) XCTFail(@"Depth first traversal order incorrect. Expected %@, got %@", depthFirst[i], data);
        i++;
    }];
    
    i = 0;
    [tree traverseTreeWithOption:SKTreeTraversalDepthLast usingBlock:^(id data, SKTreeNode *node) {
        if(![depthLast[i] isEqualToString:(NSString *)data]) XCTFail(@"Depth last traversal order incorrect. Expected %@, got %@", depthLast[i], data);
        i++;
    }];
}

-(void) testTreeFlatten {
    NSArray *df = @[@"R", @"1", @"3", @"5", @"2", @"4"];
    
    SKTreeNode *root = [[SKTreeNode alloc] initWithData:df[0]];
    SKTreeNode *n1 = [[SKTreeNode alloc] initWithData:df[1]];
    SKTreeNode *n2 = [[SKTreeNode alloc] initWithData:df[4]];
    SKTreeNode *n3 = [[SKTreeNode alloc] initWithData:df[2]];
    SKTreeNode *n4 = [[SKTreeNode alloc] initWithData:df[5]];
    SKTreeNode *n5 = [[SKTreeNode alloc] initWithData:df[3]];
    
    [root addChild:n1];
    [root addChild:n2];
    [n1 addChild:n3];
    [n2 addChild:n4];
    [n3 addChild:n5];
    SKTree *tree = [[SKTree alloc] initWithRoot:root];

    NSArray *actual = [tree flatten:SKTreeTraversalDepthFirst];
    XCTAssert([actual isEqualToArray:df], @"Not flattening correctly. Actual: %@; Expected: %@.", actual, df);
}

-(void) testFloatComparator {
    XCTAssertEqual(SKTreeComparatorFloat(@0.5, @0.5), 0, @"Comparator does not see equality.");
    XCTAssertEqual(SKTreeComparatorFloat(@0.5, @0.6), 1, @"Comparator does not see greater than.");
    XCTAssertEqual(SKTreeComparatorFloat(@0.5, @0.4), -1, @"Comparator does not see equality.");
}

-(void) testBinaryTree {
    SKTreeBinaryNode *root = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.5]];
    SKTreeBinaryNode *a = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.4]];
    SKTreeBinaryNode *b = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.6]];
    SKTreeBinaryNode *c = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.8]];
    SKTreeBinaryNode *d = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.9]];
    SKTreeBinaryNode *e = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.3]];
    SKTreeBinaryNode *f = [[SKTreeBinaryNode alloc] initWithData:[NSNumber numberWithFloat:0.45]];
    
    SKTreeBinary *tree = [[SKTreeBinary alloc] initWithRoot:root];
    [tree insertNode:a comparator:SKTreeComparatorFloat];
    [tree insertNode:b comparator:SKTreeComparatorFloat];
    [tree insertNode:c comparator:SKTreeComparatorFloat];
    [tree insertNode:d comparator:SKTreeComparatorFloat];
    [tree insertNode:e comparator:SKTreeComparatorFloat];
    [tree insertNode:f comparator:SKTreeComparatorFloat];
    
    NSArray *inorder = @[e.data, a.data, f.data, root.data, b.data, c.data, d.data];
    NSArray *preorder = [[inorder reverseObjectEnumerator] allObjects];
    NSArray *actualIn = [tree flatten:SKTreeBinaryTraversalInOrder];
    NSArray *actualPre = [tree flatten:SKTreeBinaryTraversalPreOrder];

    XCTAssertTrue([inorder isEqualToArray:actualIn], @"Inorder wrong.");
    XCTAssertTrue([preorder isEqualToArray:actualPre], @"Preorder wrong.");
}

@end
