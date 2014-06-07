
#import "SKPath.h"

/**
 * Simple class for ARC'able CGPathElements
 */
@interface SKPathElement : NSObject
@property CGPathElementType type;
@property NSArray *points;
@end

@implementation SKPathElement
@end

@interface SKPathBezierPoint : NSObject
@property CGFloat t;
@property CGPoint point;
-(CGPoint) CGPointValue;
@end

@implementation SKPathBezierPoint
-(CGPoint) CGPointValue {
    return self.point;
}
@end

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

/**
 * Invert a CGPath in a size to correct y axis
 */
+(CGPathRef) invertPath: (CGPathRef)path {
    CGRect box = CGPathGetBoundingBox(path);
    const CGAffineTransform reflect = CGAffineTransformMake(1, 0, 0, -1, 0, (box.origin.y*2) + box.size.height);
    return CGPathCreateCopyByTransformingPath(path, &reflect);
}

/*
 * DISTANCE_BETWEEN_POINTS denotes the distance
 * when interpolating between points on a curve
 * or line.
 */
#define DISTANCE_BETWEEN_POINTS 4

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
                
                [points addObjectsFromArray:[SKPath interpolateCubicBezierCurve:p1 cp1:cp1 cp2:cp2 p2:p2]];
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
                        segments:[SKPath lengthOfLine:a end:b]/DISTANCE_BETWEEN_POINTS]];
                
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

+(NSArray *) interpolateCubicBezierCurve: (CGPoint) p1 cp1: (CGPoint)cp1 cp2: (CGPoint)cp2 p2: (CGPoint)p2 {
    NSMutableArray *points = [NSMutableArray array];
    
    // Interpolate initially
    for(NSUInteger i = 0; i < 40; i++) {
        SKPathBezierPoint *p = [SKPathBezierPoint new];
        p.t = (CGFloat)i/40;
        p.point = [SKPath pointInCubicCurve:p1 controlPoint1:cp1 controlPoint2:cp2 end:p2 progress:p.t];
        [points addObject:p];
    }
    
    NSUInteger changes = 1;
    
    while(changes > 0) {
        changes = 0;
        for(NSUInteger i = 0, idx = 0, cache = points.count - 1; i < cache; i++, idx++) {
            SKPathBezierPoint *bp1 = (SKPathBezierPoint *)points[idx];
            SKPathBezierPoint *bp2 = (SKPathBezierPoint *)points[idx + 1];
            CGFloat t1 = bp1.t;
            CGFloat t2 = bp2.t;
            CGPoint c1 = bp1.point;
            CGPoint c2 = bp2.point;
            CGFloat dist = [SKPath lengthOfLine:c1 end:c2];
            
            
            if(dist > DISTANCE_BETWEEN_POINTS) {
                SKPathBezierPoint *point = [SKPathBezierPoint new];
                point.t = t1 + ((t2 - t1)/2);
                point.point = [SKPath pointInCubicCurve:p1 controlPoint1:cp1 controlPoint2:cp2 end:p2 progress:point.t];
                [points insertObject:point atIndex:++idx];
                changes++;
            }
        }
    }
    
    return points;
}

CGFloat averageDistance(NSArray *points) {
    CGFloat total = 0;
    NSUInteger count = points.count;
    for(int i = 0; i < (count - 1); i++)
        total += [SKPath lengthOfLine:((SKPathBezierPoint *)points[i]).point end:((SKPathBezierPoint *)points[i+1]).point];
    
    return total/count;
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

/**
 * Token an SVG path into [(NSString*)operation, (BOOL)relative, ...(NSNumber*)args]
 */
+(NSArray *) tokenizeSVGPath: (NSString *)pathString {
    // All of the svg operations
    NSString *svgOperations = @"MLHVZACSQTA";
    
    // Create the streaming parsers character set
    NSCharacterSet *operationsSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%@%@", svgOperations, [svgOperations lowercaseString]]];
    
    // Create the path
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSMutableArray *operations = [NSMutableArray new];
    
    // Allocate the memory for the loop
    unichar currentCharacter;
    NSMutableString *currentNumber = [NSMutableString new];
    NSMutableArray *currentOperands = [NSMutableArray new];

    for(NSUInteger i = 0, length = pathString.length; i < length; i++) {
        currentCharacter = [pathString characterAtIndex: i];
        
        // A new operation has started
        if([operationsSet characterIsMember:currentCharacter]) {
            
            if(currentNumber.length > 0) {
                // We have a current number, push
                [currentOperands addObject:[formatter numberFromString:currentNumber]];
                [currentNumber setString:@""];
            }
            
            if(currentOperands.count > 0) {
                // We have a current operation, push it to the operations array
                NSArray *token = [SKPath expandSVGToken:[NSArray arrayWithArray:currentOperands]];
                [operations addObjectsFromArray:token];
                [currentOperands removeAllObjects];
            }
            
            NSString *operation = [NSString stringWithCharacters:&currentCharacter length:1];
            // Add the operation
            [currentOperands addObject:[operation uppercaseString]];
            // Add if the operation is relative or not
            [currentOperands addObject:[NSNumber numberWithBool:![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[operation characterAtIndex:0]]]];
        } else if([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:currentCharacter] || currentCharacter == '-' || currentCharacter == '.') {
            // If we have a digit or -/., push it to the current number
            [currentNumber appendString:[NSString stringWithCharacters:&currentCharacter length:1]];
        } else if(currentCharacter == ',' || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:currentCharacter]) {
            // When we hit some whitespace, if there's any number, push it to the current operands
            if(currentNumber.length > 0) {
                [currentOperands addObject:[formatter numberFromString:currentNumber]];
                [currentNumber setString:@""];
            }
        }
    }
    
    // Push the final number to the operands
    [currentOperands addObject:currentNumber];
    
    // Push the final operation
    [operations addObject:currentOperands];
    
    return operations;
}

/**
 * Y'see, SVG spec has this shorthand think on operations
 * where operations can have more operands than they should.
 * For instance, the line to (L) operation can do this:
 *
 *    L 10,10 100,100 200,200
 *
 * This function expands the token into multiple SVG tokens i.e.
 *
 *    L 10,10 L 100,100 L 200,200
 */
+(NSArray *) expandSVGToken: (NSArray *) token {
    NSMutableArray *tokens = [NSMutableArray new];
    NSArray *fn = [token subarrayWithRange:NSMakeRange(0, 2)];
    NSDictionary *operators = @{
        @"M": @2,
        @"V": @1,
        @"H": @1,
        @"L": @2,
        @"C": @6,
        @"S": @4,
        @"Q": @4,
        @"T": @2,
        @"A": @7,
        @"Z": @0
    };
    
    NSUInteger operatorCount = [operators[token[0]] intValue];
    
    if(token.count == (operatorCount + 2)) {
        [tokens addObject:token];
        return tokens;
    }
    
    // Remove the operation and the relative flag
    NSUInteger length = floor((token.count - 2)/operatorCount);
    
    // Loop over the extra arguments and create new tokens
    for(int i = 0; i < length; i++)
        [tokens addObject:
            [fn arrayByAddingObjectsFromArray:[token subarrayWithRange:NSMakeRange(2 + (operatorCount * i), operatorCount)]]
        ];
    
    return tokens;
}

/**
 * Helper function for making relative points absolute
 */
CGPoint _relative(CGPoint current, CGPoint point) {
    return CGPointMake(current.x + point.x, current.y + point.y);
}

/**
 * Convert an SVG Path string to a CGPath.
 */
+(CGPathRef) pathFromSVGPath: (NSString *)pathString {
    NSArray *tokens = [SKPath tokenizeSVGPath:pathString];
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSMutableArray *points = [NSMutableArray new];
    
    [tokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *operation = (NSArray *)obj;
        unichar fn = [(NSString *)operation[0] characterAtIndex:0];
        BOOL relative = [operation[1] boolValue];
        
        
        switch(fn) {
            case 'M': {
                CGPoint point = CGPointMake([operation[2] floatValue], [operation[3] floatValue]);
                if(relative) point = _relative([path currentPoint], point);
                
                [path moveToPoint:point];
                break;
            }
            
            case 'H':
            case 'V':
            case 'L': {
                CGFloat x, y;
                if(fn == 'V') x = relative ? 0 : [path currentPoint].x, y = [operation[2] floatValue];
                else if(fn == 'H') y = relative ? 0 : [path currentPoint].y, x = [operation[2] floatValue];
                else x = [operation[2] floatValue], y = [operation[2] floatValue];
                
                CGPoint point = CGPointMake(x, y);
                if(relative) point = _relative([path currentPoint], point);
                
                [path addLineToPoint:point];
                break;
            }
            
            case 'Z': {
                [path closePath];
                break;
            }
            
            case 'C': {
                CGPoint cp1 = CGPointMake([operation[2] floatValue], [operation[3] floatValue]);
                CGPoint cp2 = CGPointMake([operation[4] floatValue], [operation[5] floatValue]);
                CGPoint p = CGPointMake([operation[6] floatValue], [operation[7] floatValue]);
                
                if(relative) {
                    cp1 = _relative([path currentPoint], cp1);
                    cp2 = _relative([path currentPoint], cp2);
                    p = _relative([path currentPoint], p);
                }

                [path addCurveToPoint:p controlPoint1:cp1 controlPoint2:cp2];
                
                break;
            }
            
            case 'S': {
                CGPoint cp2 = CGPointMake([operation[2] floatValue], [operation[3] floatValue]);
                CGPoint p = CGPointMake([operation[4] floatValue], [operation[5] floatValue]);
                
                if(relative) {
                    cp2 = _relative([path currentPoint], cp2);
                    p = _relative([path currentPoint], p);
                }
            
                // If the last operation was an S or C, the control point 1
                // for this operation is a reflection of the previous operation's
                // control points. If not, it's the current point.
                if(idx == 0) [NSException raise:@"InvalidSVGPath" format:@"SVG path is invalid."];
                NSArray *lastOperation = [tokens objectAtIndex:idx - 1];
                unichar lastOperationName = [lastOperation[0] characterAtIndex:0];
                CGPoint cp1;
                
                // Get the last points
                if(lastOperationName == 'S' || lastOperationName == 'C') {
                    NSUInteger offset = lastOperationName == 'S' ? 2 : 4;
                    
                    CGPoint pcp2 = CGPointMake([lastOperation[offset] floatValue], [lastOperation[offset + 1] floatValue]);
                    CGPoint pp1 = CGPointMake([lastOperation[offset + 2] floatValue], [lastOperation[offset + 3] floatValue]);
                    
                    // This isn't exactly "ideal" but if it's relative, we have
                    // to reach back another an grab it's coordinates
                    if([lastOperation[1] boolValue]) {
                        CGPoint p = [points[points.count - 2] CGPointValue];
                        pcp2 = _relative(p, pcp2);
                        pp1 = _relative(p, pp1);
                    }
                    
                    cp1 = CGPointMake(pp1.x + (pp1.x - pcp2.x), pp1.y + (pp1.y - pcp2.y));
                } else cp1 = [path currentPoint];
            
                [path addCurveToPoint:p controlPoint1:cp1 controlPoint2:cp2];
                break;
            }
            
            case 'Q': {
                CGPoint cp1 = CGPointMake([operation[2] floatValue], [operation[3] floatValue]);
                CGPoint p = CGPointMake([operation[4] floatValue], [operation[5] floatValue]);
            
                if(relative) {
                    cp1 = _relative([path currentPoint], cp1);
                    p = _relative([path currentPoint], p);
                }
            
                [path addQuadCurveToPoint:cp1 controlPoint:p];
                break;
            }
            
            case 'T': {
                CGPoint p = CGPointMake([operation[2] floatValue], [operation[3] floatValue]);
            
                if(relative)
                    p = _relative([path currentPoint], p);
            
                if(idx == 0) [NSException raise:@"InvalidSVGPath" format:@"SVG path is invalid."];
                NSArray *lastOperation = [tokens objectAtIndex:idx - 1];
                unichar lastOperationName = [lastOperation[0] characterAtIndex:0];
                CGPoint cp1;
                
                // Get the last points
                if(lastOperationName == 'Q') {
                    CGPoint pcp2 = CGPointMake([lastOperation[2] floatValue], [lastOperation[3] floatValue]);
                    CGPoint pp1 = CGPointMake([lastOperation[4] floatValue], [lastOperation[5] floatValue]);
                    
                     if([lastOperation[1] boolValue]) {
                        CGPoint p = [points[points.count - 2] CGPointValue];
                        pcp2 = _relative(p, pcp2);
                        pp1 = _relative(p, pp1);
                    }
                    
                    cp1 = CGPointMake(pp1.x + (pp1.x - pcp2.x), pp1.y + (pp1.y - pcp2.y));
                } else cp1 = [path currentPoint];
                
                [path addQuadCurveToPoint:p controlPoint:cp1];
                break;
            }
            
            case 'A': {
                [NSException raise:@"UnsupportedSVGOperation" format:@"The 'A' and 'a' operations are unsupported in this version of SKMech."];
                
                // CGFloat rx = [operation[2] floatValue];
                // CGFloat ry = [operation[3] floatValue];
                // CGFloat xAxisRotation = [operation[4] floatValue];
                // CGFloat largeArcFlag = [operation[5] boolValue];
                // CGFloat sweepFlag = [operation[6] boolValue];
                // CGPoint endpoint = CGPointMake([operation[7] floatValue], [operation[8] floatValue]);
                
                // if(relative) endpoint = _relative([path currentPoint], endpoint);
                
                // Apply the flags
                // if(sweepFlag) rx *= -1, ry *= -1;
                
                // Right, now we need to add two quad curves
                // CGPoint p = [path currentPoint];
                // CGPoint cp1 = CGPointMake(0, ry);
                // CGPoint p2 = CGPointMake(rx, ry);
                // CGPoint cp2 = CGPointMake(2*rx, ry);
                
                // Okay the specification (http://www.w3.org/TR/SVG11/paths.html) is incredibly
                // vague for the largeArcFlag and sweepFlag options in this operation so I'm not
                // particulary sure how to implement this. Maybe with some of the CGPath* operations
                // on the CGPathRef of the UIBezierPath. Anyone more versed in SVG willing to implement
                // this?
                
                // This is useless with rx AND ry.
                // [path addArcWithCenter: .. radius: .. startAngle: .. endAngle: .. clockwise: ..]; ?
                
                break;
            }
        }
        
        [points addObject:[NSValue valueWithCGPoint:[path currentPoint]]];
    }];
    
    return path.CGPath;
}

/**
 * Get the distance between each of the points in an
 * interpolated path.
 */
+(CGFloat) getLengthOfInterpolatedPath:(NSArray *)path {
    CGFloat length = 0;
    for(NSUInteger i = 0, l = path.count - 1; i < l; i++)
        length += [SKPath lengthOfLine:[path[i] CGPointValue] end:[path[i+1] CGPointValue]];
    
    return length;
}

/**
 * Get the length of a CGPath
 */
+(CGFloat) getLengthOfPath:(CGPathRef)path {
    return [SKPath getLengthOfInterpolatedPath:[SKPath interpolatePath:path]];
}
@end