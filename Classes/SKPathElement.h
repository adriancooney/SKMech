/**
 * SKPathElement is just a proxy
 * class convertin CGPathElement
 * to a storeable Object.
 */
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SKPathElement : NSObject
@property CGPathElementType type;
@property NSArray *points;
@end