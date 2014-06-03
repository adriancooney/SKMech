//
//  SKPath.m
//  SKMech
//
//  Created by Adrian Cooney on 01/06/2014.
//  Copyright (c) 2014 Adrian Cooney. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SKPath.h"

@interface SKPathTest : XCTestCase

@end

@implementation SKPathTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPointInLine
{
    CGPoint a = CGPointMake(0, 0);
    CGPoint b = CGPointMake(100, 100);
    CGPoint expectedMid = CGPointMake(50, 50);
    CGPoint actualMid = [SKPath pointInLine:a end:b progress:0.5];
    
    XCTAssertEqual(expectedMid.x, actualMid.x, @"Actual x not equal to expected x.");
    XCTAssertEqual(expectedMid.y, actualMid.y, @"Actual y not equal to expected y.");
}

-(void)testSVGTokenize {

    NSString *safe = @"M70.062,0c0,0,4.478,-171.274,119.938,320s110.15,320,110.15,320";
    NSString *spaces = @"M 70.062 0 c 0 0 4.478 -171.274 119.938 320 s 110.15 320 110.15 320";
    NSString *multiple = @"M 70 50 L 90 100 150 150 200 250 Z";
    
//    NSLog(@"%@", [SKPath tokenizeSVGPath: safe]);
}

-(void)testSVGParse {
    NSString *safe = @"M70.062,0c0,0,4.478,-171.274,119.938,320s110.15,320,110.15,320";
    [SKPath parseSVGPath:safe];
}


@end
