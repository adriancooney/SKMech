//
//  SKTreeBinarySearch.m
//  SKMech
//
//  Created by Adrian Cooney on 04/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKTreeBinary.h"

NSComparisonResult(^SKTreeComparatorFloat)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2){
    float result = [(NSNumber *)obj1 floatValue] - [(NSNumber *)obj2 floatValue];
    if(result > 0) return -1;
    else if(result < 0) return 1;
    else return 0;
};

@implementation SKTreeBinary
-(id) init {
    [NSException raise:@"BinaryTreeNullRootNode" format:@"Attempting to initilize binary search tree with null root node."];
    return nil;
}

-(id) initWithRoot: (SKTreeBinaryNode *)root {
    if(self = [super init]) {
        self.root = root;
    }
    
    return self;
}

-(void) insertNode: (SKTreeBinaryNode *)node comparator: (NSComparator)comparator {
    insertNode(node, self.root, comparator);
}


-(SKTreeBinaryNode *) findNode: (id)data comparator: (NSComparator)comparator {
    return findNodeBinary(data, self.root, comparator);
}

-(void) traverseTreeWithOption: (SKTreeBinaryTraversalOption)traversalType usingBlock: (void (^)(id data, SKTreeBinaryNode* node))block {
    if(traversalType == SKTreeBinaryTraversalInOrder || traversalType == SKTreeBinaryTraversalPreOrder)
        traverseOrder(self.root, 0, traversalType == SKTreeBinaryTraversalInOrder ? YES : NO, (__bridge void *)block);
    
}

-(NSArray *) flatten: (SKTreeBinaryTraversalOption)traversal {
    NSMutableArray *items = [NSMutableArray new];
    [self traverseTreeWithOption:traversal usingBlock:^(id data, SKTreeNode *node) {
        [items addObject:data];
    }];
    
    return (NSArray *)items;
}

void traverseOrder(SKTreeBinaryNode *node, NSUInteger depth, bool direction, void* callback) {
    void (^block)(id data, SKTreeBinaryNode* node) = (__bridge void (^)(id data, SKTreeBinaryNode* node))callback;
    
    SKTreeBinaryNode *firstNode = direction ? node.left : node.right;
    SKTreeBinaryNode *secondNode = !direction ? node.left : node.right;

    if(firstNode) traverseOrder(firstNode, depth + 1, direction, callback);
    block(node.data, node);
    if(secondNode) traverseOrder(secondNode, depth + 1, direction, callback);
}

void insertNode(SKTreeBinaryNode *newNode, SKTreeBinaryNode *treeNode, NSComparator comparator) {
    NSComparisonResult result = comparator(treeNode.data, newNode.data);
    NSLog(@"Attempting to insert %@ node into %@. Comparision results: %i", newNode.data, treeNode.data, result);
    if(result == -1) {
        if(treeNode.left == NULL) NSLog(@"Inserting in left node of %@", treeNode.data), treeNode.left = newNode;
        else insertNode(newNode, treeNode.left, comparator);
    } else if(result == 1) {
        if(treeNode.right == NULL) NSLog(@"Inserting in right node of %@", treeNode.data), treeNode.right = newNode;
        else insertNode(newNode, treeNode.right, comparator);
    }
}

SKTreeBinaryNode* findNodeBinary(id data, SKTreeBinaryNode *treeNode, NSComparator comparator) {
    NSComparisonResult result = comparator(data, treeNode.data);
    
    if(result == -1 || result == 1) {
        SKTreeBinaryNode *node = result == -1 ? treeNode.left : treeNode.right;
        if(!node) return Nil;
        else return findNodeBinary(data, node, comparator);
    } else return treeNode;
}

@end
