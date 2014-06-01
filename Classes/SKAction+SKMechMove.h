//
//  SKAction+SKMechMove.h
//  SKMech
//
//  Created by Adrian Cooney on 31/05/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//
#import <SpriteKit/SpriteKit.h>
#import "SKEasing.h"

@interface SKAction (SKMech)
+(SKAction *) customActionWithStart: (void (^)(SKNode *node)) start
    progress: (void (^)(SKNode *node, CGFloat elapsedTime, CGFloat progress)) progress
    end: (void (^)(SKNode *node)) end duration: (NSTimeInterval) duration;
    
+(SKAction *) moveTo: (CGPoint) point duration: (NSTimeInterval) duration easing: (SKEasing *) easing;
+(SKAction *) followPath: (CGPathRef) path duration: (NSTimeInterval) duration easing: (SKEasing *) easing;

+(NSArray *) getPointsAlongCGPath: (CGPathRef) path;
+(CGPoint) calculateBezierPointAtT: (CGFloat)t p0: (CGPoint)p0 p1: (CGPoint)p1 p2: (CGPoint)p2 p3: (CGPoint)p3;
+(CGPoint) calculateQuadPointAtT: (CGFloat)t p0: (CGPoint)p0 p1: (CGPoint)p1 p2: (CGPoint)p2;
@end
