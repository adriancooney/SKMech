
#import "SKPath.h"

/**
 * CGPathApplierFunction sent to CGPathApply to push CGPathElement
 * into NSArray of SKPathElement.
 */
void processPathElement(void* info, const CGPathElement* element) {
    NSMutableArray *elements = (__bridge NSMutableArray *)info;
    SKPathElement *elem = [SKPathElement new];
    NSMutableArray *points = [NSMutableArray new];
    elem.type = element->type;
    
    switch (element->type) {
        case kCGPathElementAddCurveToPoint:
            [points addObject:[NSValue valueWithCGPoint:element->points[0]]];
            [points addObject:[NSValue valueWithCGPoint:element->points[1]]];
            [points addObject:[NSValue valueWithCGPoint:element->points[2]]];
        break;
        
        case kCGPathElementAddQuadCurveToPoint:
            [points addObject:[NSValue valueWithCGPoint:element->points[0]]];
            [points addObject:[NSValue valueWithCGPoint:element->points[1]]];
        break;
        
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
            [points addObject:[NSValue valueWithCGPoint:element->points[0]]];
        break;
        
        case kCGPathElementCloseSubpath: break;
    }
    
    elem.points = points;
    [elements addObject:elem];
}

@implementation SKPath
/**
 * Convert CGPath to NSArray of SKPathElements.
 */
+(NSArray *) pathToArray: (CGPathRef)path {
    NSMutableArray *elements = [NSMutableArray new];
    CGPathApply(path, (__bridge void *)(elements), processPathElement);
    return elements;
}


/*
 * SEGMENTS denotes the amount of segments a
 * curve should be divided into.
 * TODO: Do this pragmatically.
 */
#define SEGMENTS 40

/**
 * Interpolate a CGPath and return an NSArray
 * of NSPoints along the the path. To convert 
 * NSPoint to CGPoint, make sure CoreGraphics 
 * is imported and do:
 *
 *    CGPoint p = [my_ns_point CGPointValue]
 *
 */
+(NSArray *) interpolatePath:(CGPathRef)path {
    NSArray *elements = [SKPath pathToArray:path];
    NSMutableArray *points = [NSMutableArray new];
    
    for (NSUInteger i = 0, cache = [elements count]; i < cache; i++) {
        SKPathElement *element = elements[i];
        
        switch(element.type) {
            case kCGPathElementAddCurveToPoint: {
                CGPoint p1 = [[points lastObject] CGPointValue];
                CGPoint cp1 = [element.points[0] CGPointValue];
                CGPoint cp2 = [element.points[1] CGPointValue];
                CGPoint p2 = [element.points[2] CGPointValue];
                
                for(CGFloat i = 0.0f, incr = 1.0f/(CGFloat)SEGMENTS; i <= 1.000001f; i += incr) {
                    [points addObject:
                        [NSValue valueWithCGPoint:[SKPath pointInCubicCurve:p1 controlPoint1:cp1 controlPoint2:cp2 end:p2 progress:i]]
                    ];
                }
                break;
            }
            
            case kCGPathElementAddQuadCurveToPoint: {
                CGPoint p1 = [[points lastObject] CGPointValue];
                CGPoint cp1 = [element.points[0] CGPointValue];
                CGPoint p2 = [element.points[1] CGPointValue];
                for(CGFloat i = 0.0f, incr = 1.0f/(CGFloat)SEGMENTS; i <= 1.000001f; i += incr) {
                    [points addObject:
                        [NSValue valueWithCGPoint:[SKPath pointInQuadCurve:p1 controlPoint:cp1 end:p2 progress:i]]
                    ];
                }
                break;
            }
            
            case kCGPathElementMoveToPoint: {
                [points addObject: element.points[0]];
                break;
            }
            
            case kCGPathElementCloseSubpath:
            case kCGPathElementAddLineToPoint: {
                CGPoint a = [[points lastObject] CGPointValue];
                CGPoint b;
                
                if(element.type == kCGPathElementCloseSubpath) {
                    b = [points[0] CGPointValue];
                } else {
                    b = [element.points[0] CGPointValue];
                }
                
                [points addObjectsFromArray:
                    [SKPath interpolateLineSegment: a
                        end: b
                        segments:[SKPath lengthOfLine:a end:b]/3]];
                
                [points addObject:[NSValue valueWithCGPoint:b]];
                break;
            }
            
        }
    }
    
    return points;
}

/**
 * Interpolate a line between two points
 * and return an NSArray of NSPoints going
 * from a to b.
 */
+(NSArray *) interpolateLineSegment:(CGPoint)start end:(CGPoint)end segments:(NSUInteger)segments {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:segments];
    
    for(CGFloat i = 0.0f, incr = 1.0f/(CGFloat)segments; i <= 1.000001f; i += incr)
        [points addObject:[NSValue valueWithCGPoint:
            [SKPath pointInLine:start end:end progress:i]
        ]];
    
    return points;
}

/**
 * Return the distance between two points.
 */
+(CGFloat) lengthOfLine: (CGPoint)start end: (CGPoint)end {
    return sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2));
}

/**
 * Return a point between two points at a percent.
 */
+(CGPoint) pointInLine:(CGPoint)start end:(CGPoint)end progress:(CGFloat)t {
    return CGPointMake(start.x - ((start.x - end.x) * t), start.y - ((start.y - end.y) * t));
}

/**
 * Quad curve interpolation.
 */
+(CGPoint) pointInQuadCurve:(CGPoint)p1 controlPoint:(CGPoint)cp end:(CGPoint)p2 progress:(CGFloat)t{
    CGPoint d1 = [SKPath pointInLine:p1 end:cp progress:t];
    CGPoint d2 = [SKPath pointInLine:cp end:p2 progress:t];
    return [SKPath pointInLine:d1 end:d2 progress:t];
}

/**
 * Cubic curve interpolation.
 */
+(CGPoint) pointInCubicCurve:(CGPoint)p1 controlPoint1:(CGPoint)cp1 controlPoint2:(CGPoint)cp2 end:(CGPoint)p2 progress:(CGFloat)t {
    CGPoint d1 = [SKPath pointInQuadCurve:p1 controlPoint:cp1 end:cp2 progress:t];
    CGPoint d2 = [SKPath pointInQuadCurve:cp1 controlPoint:cp2 end:p2 progress:t];
    return [SKPath pointInLine:d1 end:d2 progress:t];
}

/**
 * Quntic curve interpolation.
 */
+(CGPoint) pointInQunticCurve:(CGPoint)p1 controlPoint1:(CGPoint)cp1 controlPoint2:(CGPoint)cp2 controlPoint3:(CGPoint)cp3 end:(CGPoint)p2 progress:(CGFloat)t {
    CGPoint d1 = [SKPath pointInCubicCurve:p1 controlPoint1:cp1 controlPoint2:cp2 end:cp3 progress:t];
    CGPoint d2 = [SKPath pointInCubicCurve:cp1 controlPoint1:cp2 controlPoint2:cp3 end:p2 progress:t];
    return [SKPath pointInLine:d1 end:d2 progress:t];
}
@end
