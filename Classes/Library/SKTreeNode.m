//
//  SKTreeNode.m
//  SKMech
//
//  Created by Adrian Cooney on 03/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKTreeNode.h"

@implementation SKTreeNode
-(id) init {
    if(self = [super init]) {
        self.children = [NSMutableArray new];
    }
    
    return self;
}

-(id) initWithCapacity: (NSUInteger)capacity {
    if(self = [super init]) {
        self.children = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    
    return self;
}

-(id) initWithParent: (SKTreeNode *)node {
    if(self = [self init]) {
        self.parent = node;
    }
    
    return self;
}

-(id) initWithData: (id)data {
    if(self = [self init]) {
        self.data = data;
    }
    
    return self;
}

-(void) addChild: (SKTreeNode *)child {
    [self.children addObject:child];
}
@end
