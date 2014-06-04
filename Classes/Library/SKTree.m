//
//  SKTree.m
//  SKMech
//
//  Created by Adrian Cooney on 03/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKTree.h"

@implementation SKTree
-(id) init {
    if(self = [super init]) {
        if(!self.root) self.root = [SKTreeNode new];
    }
    
    return self;
}

-(id) initWithRoot: (SKTreeNode *)root {
    if(self = [super init]) {
        self.root = root;
    }
    
    return self;
}

-(NSArray *) flatten: (SKTreeTraversalOption)traversal {
    NSMutableArray *items = [NSMutableArray new];
    [self traverseTreeWithOption:traversal usingBlock:^(id data, SKTreeNode *node) {
        [items addObject:data];
    }];
    
    return (NSArray *)items;
}

-(void) traverseTreeWithOption: (SKTreeTraversalOption)traversalType usingBlock: (void (^)(id data, SKTreeNode* node))block {
    if(traversalType == SKTreeTraversalBreadthFirst || traversalType == SKTreeTraversalBreadthLast)
        traverseDepth(self.root, 0, traversalType == SKTreeTraversalDepthFirst ? YES : NO, (__bridge void *)(block));
    else [NSException raise:@"UnknownTraversalMethod" format:@"Unknown traversal method."];
}

/**
 * Depth first traversal of the tree. Direction: YES for right, NO for left
 */
void traverseDepth(SKTreeNode *node, NSUInteger depth, bool direction, void* callback) {
    void (^block)(id data, SKTreeNode* node) = (__bridge void (^)(id data, SKTreeNode* node))callback;
    block(node.data, node);
    
    NSArray *children = node.children;
    NSUInteger i = direction ? 0 : (children.count - 1);
    NSUInteger v = direction ? children.count : 0;
    
    if(children.count > 0) {
        for(; i < v; i++) traverseDepth(children[direction ? i : (children.count-1) - i], depth + 1, direction, callback);
    }
}

SKTreeNode* findNode(id data, SKTreeNode *treeNode, NSComparator comparator) {
    NSComparisonResult result = comparator(data, treeNode.data);
    
    if(result == 0) return treeNode;
    else {
        for(NSUInteger i = 0, length = treeNode.children.count; i < length; i++) {
            SKTreeNode* node = findNode(data, treeNode.children[i], comparator);
            if(node) return node;
        }
    }
    
    return nil;
}

@end
