
#import "SKEasing.h"

static SKEasing *_linearEasing, *_easeOutEasing, *_easeInEasing;

@implementation SKEasing
/**
 * Initilize some easings
 * TODO: Make more easings.
 * TODO: Precalculate easings.
 */
+ (void) initialize {
    if (self == [SKEasing class]) {
        _linearEasing = [[SKEasing alloc] initWithCustomEasingFunction:^CGFloat(CGFloat x) {
            return x;
        }];
        
        // Easings taken from http://www.flong.com/texts/code/shapers_poly/
        _easeInEasing = [[SKEasing alloc] initWithCustomEasingFunction:^CGFloat(CGFloat x) {
            float a = 0.7;
            float b = 0.4;
            float epsilon = 0.00001;
            float min_param_a = 0.0 + epsilon;
            float max_param_a = 1.0 - epsilon;
            float min_param_b = 0.0;
            float max_param_b = 1.0;
            a = fmin(max_param_a, fmax(min_param_a, a));
            b = fmin(max_param_b, fmax(min_param_b, b));

            float A = (1-b)/(1-a) - (b/a);
            float B = (A*(a*a)-b)/a;
            float y = A*(x*x) - B*(x);
            y = fmin(1, fmax(0,y));

            return y;
        }];
        
        _easeOutEasing = [[SKEasing alloc] initWithCustomEasingFunction:^CGFloat(CGFloat x) {
            float a = 0.4;
            float b = 0.7;
            float epsilon = 0.00001;
            float min_param_a = 0.0 + epsilon;
            float max_param_a = 1.0 - epsilon;
            float min_param_b = 0.0;
            float max_param_b = 1.0;
            a = fmin(max_param_a, fmax(min_param_a, a));
            b = fmin(max_param_b, fmax(min_param_b, b));

            float A = (1-b)/(1-a) - (b/a);
            float B = (A*(a*a)-b)/a;
            float y = A*(x*x) - B*(x);
            y = fmin(1, fmax(0,y));

            return y;
        }];
    }
}

// Easing accessors
+(SKEasing *) linear { return _linearEasing; }
+(SKEasing *) easeOut { return _easeOutEasing; }
+(SKEasing *) easeIn { return _easeInEasing; }

/**
 * Create SKEasing with custom easing function.
 * Takes in variable CGFloat x (0-1) and returns 
 * CGFloat y (0-1).
 */
-(id) initWithCustomEasingFunction:(CGFloat (^)(CGFloat))customEasingFunction {
    if(self = [super init]) {
        customEasing = customEasingFunction;
    }
    
    return self;
}

/**
 * Initilize easing with easing data (NSArray of
 * NSNumbers between 0-1.
 */
+(SKEasing *) initWithEasingData:(NSArray *)data {
    CGFloat interval = 1/[data count];
    return [[SKEasing alloc] initWithCustomEasingFunction:^CGFloat(CGFloat x) {
        CGFloat currentIntervalProgress = fmod(x, interval);
        NSInteger index = floor((x - currentIntervalProgress)/interval);
        CGFloat u = [[data objectAtIndex:index] floatValue];
        
        if(index < ([data count] - 1)) {
            CGFloat v = [[data objectAtIndex:index + 1] floatValue];
            return [SKEasing interpolateU:u withV:v point:currentIntervalProgress];
        } else return u;
    }];
}

/**
 * Return the easing value at a percent (0-1)
 */
-(CGFloat) progress: (CGFloat) point {
    if(point > 1 || point < 0) [NSException raise:@"SKEasingProgressRangeError" format:@"Progress queried at point not in the range of 0-1 (%f).", point];
    
    return customEasing(point);
}

/**
 * Interpolate between two values at a percent (0-1)
 *
 * Examples:
 * v > u
 * u = 0, v = 1, p = 0.5 -> 0.5
 * u = -1, v = 1, p = 0.5 -> 0
 * u = 0, v = 10, p = 0.6 -> 6
 * u = -100, v = 100, p = 0.7 -> 40
 *
 * u > v
 * u = 2, v = -6, p = 0.75 -> -4
 * u = 10, v = 0, p = 0.8 -> 2
 */
+(CGFloat) interpolateU: (CGFloat) u withV: (CGFloat) v point: (CGFloat) p {
    if(u > v) {
        return u - ((u - v) * p);
    } else if(u < v) {
        return u + ((v - u) * p);
    } else return u;
}
@end
