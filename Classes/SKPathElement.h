//
//  SKPathElement.h
//  SKMech
//
//  Created by Adrian Cooney on 01/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SKPathElement : NSObject
@property CGPathElementType type;
@property NSArray *points;
@end