//
//  SKTreeBinaryNode.h
//  SKMech
//
//  Created by Adrian Cooney on 03/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTreeNode.h"

@interface SKTreeBinaryNode : SKTreeNode {
    NSInteger __left;
    NSInteger __right;
}

@property (nonatomic, retain) NSMutableArray* children;
@property (nonatomic, retain) SKTreeBinaryNode* left;
@property (nonatomic, retain) SKTreeBinaryNode* right;

-(id) initWithParent: (SKTreeNode *)node;
-(id) initWithData: (id)data;
@end
