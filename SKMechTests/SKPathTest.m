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



@end
