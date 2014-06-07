//
//  SKTreeBinarySearch.h
//  SKMech
//
//  Created by Adrian Cooney on 04/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKTree.h"
#import "SKTreeBinaryNode.h"

typedef NS_ENUM(NSUInteger, SKTreeBinaryTraversalOption) {
    SKTreeBinaryTraversalInOrder,
    SKTreeBinaryTraversalPreOrder
};

NSComparisonResult(^SKTreeComparatorFloat)(id obj1, id obj2);

@interface SKTreeBinary : SKTree
@property SKTreeBinaryNode* root;

-(id) initWithRoot: (SKTreeBinaryNode *)root;
-(void) insertNode: (SKTreeBinaryNode *)node comparator: (NSComparator)comparator;
-(void) traverseTreeWithOption: (SKTreeBinaryTraversalOption)traversalType usingBlock: (void (^)(id data, SKTreeBinaryNode* node))block;
-(NSArray *) flatten: (SKTreeBinaryTraversalOption)traversal;
-(SKTreeBinaryNode *) findNode: (id)data comparator: (NSComparator)comparator;
@end
