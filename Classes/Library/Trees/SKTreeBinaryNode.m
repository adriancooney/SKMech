//
//  SKTreeBinaryNode.m
//  SKMech
//
//  Created by Adrian Cooney on 03/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKTreeBinaryNode.h"

@implementation SKTreeBinaryNode

-(id) init {
    if(self = [super init]) {
        __left = -1;
        __right = -1;
    }
    
    return self;
}

-(id) initWithParent: (SKTreeNode *)node {
    if(self = [self init]) {
        self.parent = node;
    }
    
    return self;
}

-(id) initWithData:(id)data {
    if(self = [self init]) {
        self.data = data;
    }
    
    return self;
}

-(SKTreeBinaryNode *) left {
    if(__left > -1) return self.children[__left];
    else return nil;
}

-(void) setLeft:(SKTreeBinaryNode *)left {
    __left = __left > -1 ? __left : (__right > -1 ? 1 - __right : 0);
    self.children[__left] = left;

}

-(SKTreeBinaryNode *) right {
    if(__right > -1) return self.children[__right];
    else return nil;
}

-(void) setRight:(SKTreeBinaryNode *)right {
    __right = __right > -1 ? __right : (__left > -1 ? 1 - __left : 0);
    self.children[__right] = right;
}

@end
