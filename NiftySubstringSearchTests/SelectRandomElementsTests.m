//
//  SelectRandomElementsTests.m
//  NiftySubstringSearchTests
//
//  Created by g00dm0us3 on 7/10/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+SelectRandomElements.h"

@interface SelectRandomElementsTests : XCTestCase

@end

@implementation SelectRandomElementsTests


- (void)testSelectRandomElements
{
    NSArray<NSNumber *> *indicies = @[@(7),@(8),@(9),@(10),@(14),@(15),@(16),@(17),@(18),@(19),@(110)];

    for (int i = 0; i < 100; i++) {
        NSArray<NSNumber *> *res = [indicies selectRandomElements:6];
        NSMutableSet<NSNumber *> *taken = [NSMutableSet set];
        for (NSNumber *idx in res) {
            XCTAssert(![taken containsObject:idx], @"Repetition!");
            [taken addObject:idx];
        }
    }

    NSUInteger C5of11 = 462;  // number of ways to select 5 elements from 11
    float avgPercentOfUniqueSelectionsGenerated = 0;

    for (int j = 0; j < 100; j++) {
        NSUInteger k = 0;
        NSMutableSet<NSString *> *combinations = [NSMutableSet set];

        for (int i = 0; i < C5of11; i++) { // go over all of the different unordered subsets of size 5 of 11 elements.
            NSArray<NSNumber *> *res = [indicies selectRandomElements:5];
            NSString *rep = [res componentsJoinedByString:@","];
            if (![combinations containsObject:rep]) { // since we are selecting uniformly at random, each subset should be encountered ~ once
                k++;
                [combinations addObject:rep];
            }
        }
        float percentOfUniqueSelectionsGenerated = (k/(C5of11*1.0f))*100;
        avgPercentOfUniqueSelectionsGenerated += percentOfUniqueSelectionsGenerated;
    }

    // should be reasonably close to 100%, since we are aiming to get each possible random selection with the same probability

    avgPercentOfUniqueSelectionsGenerated /= 100;

    XCTAssert(avgPercentOfUniqueSelectionsGenerated >= 98, @"Selection non uniform");

    NSLog(@"%.2f%%", avgPercentOfUniqueSelectionsGenerated);
}

@end
