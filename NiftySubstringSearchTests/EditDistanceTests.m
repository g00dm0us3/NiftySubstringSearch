//
//  EditDistanceTests.m
//  NiftySubstringSearchTests
//
//  Created by g00dm0us3 on 7/9/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+EditDistanceDP.h"
#import "EditDistance.h"
#import "UTF8CharacterSequence.h"

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

- (void)testEditDistanceFastUkkonen
{
    NSString *text = [self generateString:500];
    NSString *pattern = [self removeNSymbols:10 from:text];

    NSUInteger editDistanceGT = [text editDistanceDP:pattern];
    
    NSInteger editDistance = 0;
    
    UTF8CharacterSequence *textBuf = [UTF8CharacterSequence sequenceWithString:text];
    UTF8CharacterSequence *patternBuf = [UTF8CharacterSequence sequenceWithString:pattern];
    
    editDistance = [EditDistance fastEditDistance:textBuf textRange:NSMakeRange(0, textBuf.length) pattern:patternBuf];

    XCTAssertEqual(editDistance, editDistanceGT, @"Wrong distance");
    
    editDistance = 0;
    
    editDistance =  [EditDistance fastEditDistance:patternBuf textRange:NSMakeRange(0, patternBuf.length) pattern:textBuf];

    XCTAssertEqual(editDistance, editDistanceGT, @"Wrong distance");
}

-(NSString *) generateString:(NSUInteger)ofLength {
    NSArray<NSString *> *letters = @[@"A", @"T", @"G", @"C"];
    
    NSMutableString *str = [NSMutableString new];
    
    for (int i = 0; i < ofLength; i++) {
        [str appendString:letters[arc4random_uniform(3)]];
    }
    
    return (NSString *)str;
}

- (NSString *) removeNSymbols:(NSUInteger)n from:(NSString *)string {
    NSMutableString *str = [NSMutableString stringWithString:string];
    
    for (int i = 0; i < n; i++) {
        int idx = arc4random_uniform(str.length-1);
        [str deleteCharactersInRange:NSMakeRange(idx, 1)];
    }
    
    return (NSString *)str;
}

- (void)testEditDistanceInternalUkkonen
{
    NSString *text = @"CCGGAG";
    NSString *pattern = @"AAGGTTCC";

    NSUInteger editDistanceGT = [text editDistanceDP:pattern];
    
    NSInteger editDistance = 0;
    
    UTF8CharacterSequence *textBuf = [UTF8CharacterSequence sequenceWithString:text];
    UTF8CharacterSequence *patternBuf = [UTF8CharacterSequence sequenceWithString:pattern];
    
    BOOL res = [EditDistance internalEditDistanceUkkonen: textBuf textRange:NSMakeRange(0, textBuf.length) pattern:[UTF8CharacterSequence sequenceWithString:pattern] maxEditDistance:8 result:&editDistance];

    XCTAssertTrue(res, "Cannot calculate distance");
    XCTAssertEqual(editDistance, editDistanceGT, @"Wrong distance");
    
    editDistance = 0;
    
    res = [EditDistance internalEditDistanceUkkonen:patternBuf textRange:NSMakeRange(0, patternBuf.length) pattern:textBuf maxEditDistance:8 result:&editDistance];
    XCTAssertTrue(res, "Cannot calculate distance");
    XCTAssertEqual(editDistance, editDistanceGT, @"Wrong distance");
}

@end
