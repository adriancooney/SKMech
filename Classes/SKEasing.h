//
//  SKEasing.h
//  SKMech
//
//  Created by Adrian Cooney on 31/05/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

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
