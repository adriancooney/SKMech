//
//  SKAction+SKMechMove.m
//  SKMech
//
//  Created by Adrian Cooney on 31/05/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKAction+SKMechMove.h"

// Source: http://stackoverflow.com/questions/4058979/find-a-point-a-given-distance-along-a-simple-cubic-bezier-curve-on-an-iphone
CGFloat bezierInterpolation(CGFloat t, CGFloat a, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat t2 = t * t;
    CGFloat t3 = t2 * t;
    return a + (-a * 3 + t * (3 * a - a * t)) * t
    + (3 * b + t * (-6 * b + b * 3 * t)) * t
    + (c * 3 - c * 3 * t) * t2
    + d * t3;
}

float CubicBezier(float t, float start, float c1, float c2, float end)
{
    CGFloat t_ = (1.0 - t);
    CGFloat tt_ = t_ * t_;
    CGFloat ttt_ = t_ * t_ * t_;
    CGFloat tt = t * t;
    CGFloat ttt = t * t * t;
    
    return start * ttt_
    + 3.0 *  c1 * tt_ * t
    + 3.0 *  c2 * t_ * tt
    + end * ttt;
}

CGPoint CubicBezierPoint(CGFloat t, CGPoint start, CGPoint c1, CGPoint c2, CGPoint end)
{
    CGPoint result;
    result.x = CubicBezier(t, start.x, c1.x, c2.x, end.x);
    result.y = CubicBezier(t, start.y, c1.y, c2.y, end.y);
    return result;
}

@implementation SKAction (SKMech)
+(SKAction *) moveTo:(CGPoint)point duration:(NSTimeInterval)duration easing:(SKEasing *)easing {
    __block CGPoint startPoint, translation;
    
    return [SKAction customActionWithStart:^(SKNode *node) {
        startPoint = node.position;
        CGFloat tx = -1 * (startPoint.x - point.x);
        CGFloat ty = -1 * (startPoint.y - point.y);
        translation = CGPointMake(tx, ty);
    } progress:^(SKNode *node, CGFloat elapsedTime, CGFloat progress) {
        CGFloat ease = [easing progress:progress];
        node.position = CGPointMake(startPoint.x + (translation.x * ease), startPoint.y + (translation.y * ease));
    } end:^(SKNode *node) {
        node.position = point;
    } duration:duration];
}

+(SKAction *) customActionWithStart: (void (^)(SKNode *node)) start
    progress: (void (^)(SKNode *node, CGFloat elapsedTime, CGFloat progress)) progress
    end: (void (^)(SKNode *node)) end duration: (NSTimeInterval) duration {
    
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        if(elapsedTime == 0) start(node);
        progress(node, elapsedTime, elapsedTime/duration);
        if(elapsedTime == duration) end(node);
    }];
}


+(SKAction *) followPath: (CGPathRef) path duration: (NSTimeInterval) duration easing: (SKEasing *) easing {
    
    
}

+(NSArray *) getPointsAlongCGPath: (CGPathRef) path {
    NSMutableArray *points = [NSMutableArray new];
    CGPathApply(path, (__bridge void *)(points), processPathElement);
    return points;
}

//+(CGPoint) calculateBezierPointAtT: (CGFloat)t p0: (CGPoint)p0 p1: (CGPoint)p1 p2: (CGPoint)p2 p3: (CGPoint)p3 {
//    return CGPointMake(bezierInterpolation(t, p0.x, p1.x, p2.x, p3.x), bezierInterpolation(t, p0.y, p1.y, p2.y, p3.y));
//}

//+(CGPoint) calculateBezierPointAtT:(CGFloat)t p0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 {
//    CGFloat lx = p0.x + (t * (p0.x - p1.x) * -1);
//    CGFloat ly = p0.y + (t * (p0.y - p1.y) * -1);
//    CGFloat tx = p1.x + (t * (p1.x - p2.x) * -1);
//    CGFloat ty = p1.y + (t * (p1.y - p2.y) * -1);
//    CGFloat rx = p2.x + (t * (p2.x - p3.x) * -1);
//    CGFloat ry = p2.y + (t * (p2.y - p3.y) * -1);
//    
//    CGFloat lbx = lx + (t * (lx - tx) * -1);
//    CGFloat lby = ly + (t * (ly - ty) * -1);
//    CGFloat rbx = tx + (t * (tx - rx) * -1);
//    CGFloat rby = ty + (t * (ty - ry) * -1);
//    
//    CGFloat x = lbx + (t * (lbx - rbx) * -1);
//    CGFloat y = lby + (t * (lby - rby) * -1);
//    
//    return CGPointMake(x, y);
//}

+(CGPoint) calculateBezierPointAtT:(CGFloat)t p0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 {
    CGPoint p = CubicBezierPoint(t, p0, p1, p2, p3);
//    CGFloat dx = p.x - CubicBezier(t * 0.9, p0.x, p1.x, p2.x, p3.x);
//    CGFloat dy = p.y - CubicBezier(t * 0.9, p0.y, p1.y, p2.y, p3.y);
    return p;
}

/**
 * Source: http://stackoverflow.com/questions/5634460/quadratic-bezier-curve-calculate-point
 */
+(CGPoint) calculateQuadPointAtT: (CGFloat)t p0: (CGPoint)p0 p1: (CGPoint)p1 p2: (CGPoint)p2 {
    float x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
    float y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
    return CGPointMake(x, y);
}

#define SEGMENTS 20
void processPathElement(void* info, const CGPathElement* element) {
    NSMutableArray *points = (__bridge NSMutableArray *)info;
    
    switch (element->type) {
        case kCGPathElementAddCurveToPoint:
            // Bezier Curve
            for (int i = 0; i < SEGMENTS; i++) {
                [points addObject:[NSValue valueWithCGPoint:[SKAction calculateBezierPointAtT: ((CGFloat) i)/((CGFloat) SEGMENTS)
                    p0:[[points lastObject] CGPointValue]
                    p1:element->points[0]
                    p2:element->points[1]
                    p3:element->points[2]]]];
            }
        break;
        
        case kCGPathElementAddQuadCurveToPoint:
            for (int i = 0; i < SEGMENTS; i++) {
                [points addObject:[NSValue valueWithCGPoint:[SKAction calculateQuadPointAtT: ((CGFloat) i)/((CGFloat) SEGMENTS)
                    p0:[[points lastObject] CGPointValue]
                    p1:element->points[0]
                    p2:element->points[1]]]];
            }
            
        break;
        
        case kCGPathElementCloseSubpath:
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
            [points addObject:[NSValue valueWithCGPoint:element->points[0]]];
        break;
    }
}
@end
