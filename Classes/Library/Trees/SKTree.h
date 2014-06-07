//
//  SKTree.h
//  SKMech
//
//  Created by Adrian Cooney on 03/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTreeNode.h"

typedef NS_ENUM(NSUInteger, SKTreeTraversalOption) {
    SKTreeTraversalBreadthFirst,
    SKTreeTraversalBreadthLast,
    SKTreeTraversalDepthFirst,
    SKTreeTraversalDepthLast,
};

@interface SKTree : NSObject
@property SKTreeNode *root;

-(id) init;
-(id) initWithRoot: (SKTreeNode *)root;

-(NSArray *) flatten: (SKTreeTraversalOption)traversal;

-(void) traverseTreeWithOption: (SKTreeTraversalOption)traversalType usingBlock: (void (^)(id data, SKTreeNode* node))block;
@end