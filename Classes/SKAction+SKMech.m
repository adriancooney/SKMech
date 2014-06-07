
#import "SKAction+SKMech.h"

@implementation SKAction (SKMech)
/**
 * Move node to another point.
 */
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

/**
 * Custom SKAction with start, end and progress block.
 */
+(SKAction *) customActionWithStart: (void (^)(SKNode *node)) start
    progress: (void (^)(SKNode *node, CGFloat elapsedTime, CGFloat progress)) progress
    end: (void (^)(SKNode *node)) end duration: (NSTimeInterval) duration {
    
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        if(elapsedTime == 0) start(node);
        progress(node, elapsedTime, elapsedTime/duration);
        if(elapsedTime == duration) end(node);
    }];
}

/**
 * Make a node follow a CGPath with custom easing.
 */
#define PATH_DEBUG 0
+(SKAction *) followPath:(CGPathRef)path duration:(NSTimeInterval)duration easing:(SKEasing *)easing {
    NSArray *points = [SKPath interpolatePath:path];
    NSUInteger length = [points count];
    CGFloat interval = 1.0f/(CGFloat)length;
    
    // Enable Debugging information about the paths
#if PATH_DEBUG
    SKNode *debugPath = [SKNode node];
    NSMutableDictionary *map = [NSMutableDictionary new];
    __block CGFloat previousIndex = 0;
    __block CGFloat previousInterval = 0;
#endif
    
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat progress = elapsedTime/duration;
        CGFloat ease = [easing progress:progress];
        
        // Find point
        CGFloat mod = fmod(ease, interval);
        NSUInteger index = floor(ease * length);
        if(index < length) {
            CGPoint a = [points[index] CGPointValue];

#if PATH_DEBUG
            if(![debugPath parent]) [[node parent] addChild:debugPath];
            if(![debugPath childNodeWithName:NSStringFromCGPoint(a)]) {
                SKSpriteNode *p = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(4, 4)];
                p.position = a;
                p.name = NSStringFromCGPoint(a);
                [debugPath addChild:p];
            }

            if(elapsedTime >= (duration - 0.05)) [debugPath removeFromParent], NSLog(@"%@", map);
            
            if(index > previousIndex) previousIndex++, previousInterval = 0;
#endif
            
            if(index < (length - 1)) {
                CGPoint b = [points[index + 1] CGPointValue];
//                CGFloat intv = (mod/interval);
//                if(previousInterval > intv) NSLog(@"GREATER INTERVAL:  %f, %f, %i, %f", mod, interval, index, (ease - mod)/interval);
//                else NSLog(@"Interval progress: %f, %f, %i, %f", mod, interval, index, (ease - mod)/interval);
//                previousInterval = intv;
//                
//                NSString *num = [NSString stringWithFormat:@"%d", index];
//                NSNumber *i = map[num];
//                if(i != Nil) map[num] = [NSNumber numberWithInteger:[i integerValue] + 1];
//                else map[num] = [NSNumber numberWithInteger:0];
                CGPoint position = [SKPath pointInLine:a end:b progress:mod/interval];
                
                // Set the new position
                node.position = position;
            } else node.position = a;
        }
    }];
    
}
@end
