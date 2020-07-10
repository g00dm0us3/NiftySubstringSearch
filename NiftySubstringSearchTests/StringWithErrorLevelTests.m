//
//  StringWithErrorLevelTests.m
//  NiftySubstringSearchTests
//
//  Created by g00dm0us3 on 7/10/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+StringWithErrorLevel.h"
#import "NSString+EditDistanceDP.h"

@interface StringWithErrorLevelTests : XCTestCase

@end

@implementation StringWithErrorLevelTests

- (void)testStringWithErrorLevel
{
    NSString *text = @"abcdefghij";

    for (int i = 1; i <= 10; i++) {
        float alpha = i/10.0f;
        NSString *substring = [text stringWithErrorLevel:alpha];
        NSUInteger k = [text editDistanceDP:substring];
        NSLog(@"k : %lu, 𝛂: %f", k, alpha);

        if (k != alpha*10) {
            NSLog(@"🤬 %@, %@", text, substring);
        }
        // k = 𝛂m
        XCTAssert(k == 10*alpha, @"Edit distance should be ⎣𝛂m⎦");
    }
}

@end
