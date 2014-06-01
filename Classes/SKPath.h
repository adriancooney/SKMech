//
//  SKPath.h
//  SKMech
//
//  Created by Adrian Cooney on 01/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "SKPathElement.h"

@interface SKPath : NSObject
+(NSArray *) pathToArray: (CGPathRef) path;
+(NSArray *) interpolatePath: (CGPathRef) path;
+(NSArray *) interpolateLineSegment: (CGPoint)start end: (CGPoint)end segments: (NSUInteger)segments;

+(CGPoint) pointInLine: (CGPoint)start end: (CGPoint)end progress: (CGFloat)t;
+(CGPoint) pointInQuadCurve: (CGPoint)p1 controlPoint: (CGPoint)cp end: (CGPoint)p2 progress: (CGFloat)t;
+(CGPoint) pointInCubicCurve: (CGPoint)p1 controlPoint1: (CGPoint)cp1 controlPoint2: (CGPoint)cp2 end: (CGPoint)p2 progress: (CGFloat)t;
+(CGPoint) pointInQunticCurve: (CGPoint)p1 controlPoint1: (CGPoint)cp1 controlPoint2: (CGPoint)cp2 controlPoint3: (CGPoint)cp3 end: (CGPoint)p2 progress: (CGFloat)t;

@end
