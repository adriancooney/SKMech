//
//  SKAction+SKMechMove.m
//  SKMech
//
//  Created by Adrian Cooney on 31/05/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import "SKAction+SKMechMove.h"

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

+(SKAction *) followPath:(CGPathRef)path duration:(NSTimeInterval)duration easing:(SKEasing *)easing {
    NSArray *points = [SKPath interpolatePath:path];
    NSUInteger length = [points count];
    CGFloat interval = 1.0f/(CGFloat)length;
    
    NSLog(@"%@", points);
    
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat progress = elapsedTime/duration;
        CGFloat ease = [easing progress:progress];
        
        // Find point
        CGFloat mod = fmod(ease, interval);
        NSUInteger index = floor((ease - mod)/interval);
        if(index < length) {
            CGPoint a = [points[index] CGPointValue];
            
            NSLog(@"m = %f, i = %lu, e = %f, p = %f, l = %lu", mod, (unsigned long)index, ease, progress, length);
            
            if(index < (length - 1)) {
                CGPoint b = [points[index + 1] CGPointValue];
                CGPoint position = [SKPath pointInLine:a end:b progress:(mod/interval)];
                node.position = position;
            } else node.position = a;
        }
        
    }];
}
@end
