/*
 * SKEasing - SKMech's easing utility.
 */
 
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SKEasing : NSObject {
    CGFloat (^customEasing)(CGFloat x);
}

// Sample easings
+ (SKEasing *) linear;
+ (SKEasing *) easeOut;
+ (SKEasing *) easeIn;

+(CGFloat) interpolateU: (CGFloat) u withV: (CGFloat) v point: (CGFloat) p;
+(SKEasing *) initWithEasingData: (NSArray *) data;

-(id) initWithCustomEasingFunction: (CGFloat (^)(CGFloat x)) customEasingFunction;
-(CGFloat) progress: (CGFloat) point;
@end
