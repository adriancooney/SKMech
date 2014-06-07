//
//  SKTreeNode.h
//  SKMech
//
//  Created by Adrian Cooney on 03/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Tree node object
 */
@interface SKTreeNode : NSObject
@property (nonatomic, retain) SKTreeNode *parent;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) id userData;
@property id data;

-(id) init;
-(id) initWithParent: (SKTreeNode *)node;
-(id) initWithCapacity: (NSUInteger)capacity;
-(id) initWithData: (id)data;
-(void) addChild: (SKTreeNode *)child;
@end

