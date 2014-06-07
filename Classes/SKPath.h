/*
 * SKPath is SKMech's CGPath functions
 * which include converting CGPaths to
 * points and quad/cubic/quntic interpolation.
 */
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Library/Trees/SKTreeBinary.h"

@interface SKPath : NSObject
+(NSArray *) tokenizeSVGPath: (NSString *)path;
+(CGPathRef) pathFromSVGPath: (NSString *)path;

+(CGPathRef) invertPath: (CGPathRef)path;

+(NSArray *) pathToArray: (CGPathRef) path;

+(NSArray *) interpolatePath: (CGPathRef) path;
+(NSArray *) interpolateLineSegment: (CGPoint)start end: (CGPoint)end segments: (NSUInteger)segments;

+(CGFloat) getLengthOfInterpolatedPath: (NSArray *)path;
+(CGFloat) getLengthOfPath: (CGPathRef)path;

+(CGFloat) lengthOfLine: (CGPoint)start end: (CGPoint)end;
+(CGPoint) pointInLine: (CGPoint)start end: (CGPoint)end progress: (CGFloat)t;
+(CGPoint) pointInQuadCurve: (CGPoint)p1 controlPoint: (CGPoint)cp end: (CGPoint)p2 progress: (CGFloat)t;
+(CGPoint) pointInCubicCurve: (CGPoint)p1 controlPoint1: (CGPoint)cp1 controlPoint2: (CGPoint)cp2 end: (CGPoint)p2 progress: (CGFloat)t;
+(CGPoint) pointInQunticCurve: (CGPoint)p1 controlPoint1: (CGPoint)cp1 controlPoint2: (CGPoint)cp2 controlPoint3: (CGPoint)cp3 end: (CGPoint)p2 progress: (CGFloat)t;

@end
