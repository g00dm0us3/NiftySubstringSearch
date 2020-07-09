//
//  EditDistanceTests.m
//  NiftySubstringSearchTests
//
//  Created by g00dm0us3 on 7/9/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+EditDistanceDP.h"

@interface EditDistanceTests : XCTestCase

@end

@implementation EditDistanceTests

- (void)testEditDistanceDP
{
    NSString *text = @"ACTGGA";
    NSString *pattern = @"GCGGG";

    NSUInteger editDistance = [text editDistanceDP:pattern];

    NSString *t = text;
    text = pattern;
    pattern = t;
    NSUInteger editDistance1 = [text editDistanceDP:pattern];
    XCTAssert(editDistance1 == editDistance, @"Distance should be symmetric");
    XCTAssert(editDistance == 3, @"Wrong edit distance");
}

@end
