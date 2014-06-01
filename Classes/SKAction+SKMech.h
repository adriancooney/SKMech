//
//  SKAction+SKMechMove.h
//  SKMech
//
//  Created by Adrian Cooney on 31/05/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//
#import <SpriteKit/SpriteKit.h>
#import "SKEasing.h"
#import "SKPath.h"

@interface SKAction (SKMech)
+(SKAction *) customActionWithStart: (void (^)(SKNode *node)) start
    progress: (void (^)(SKNode *node, CGFloat elapsedTime, CGFloat progress)) progress
    end: (void (^)(SKNode *node)) end duration: (NSTimeInterval) duration;
    
+(SKAction *) moveTo: (CGPoint) point duration: (NSTimeInterval) duration easing: (SKEasing *) easing;
+(SKAction *) followPath: (CGPathRef) path duration: (NSTimeInterval) duration easing: (SKEasing *) easing;
@end
