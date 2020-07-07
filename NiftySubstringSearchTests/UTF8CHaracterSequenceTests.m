//
//  UTF8CHaracterSequenceTests.m
//  NiftySubstringSearch
//
//  Created by g00dm0us3 on 7/7/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UTF8CharacterSequence.h"

@interface UTF8CHaracterSequenceTests : XCTestCase

@end

@implementation UTF8CHaracterSequenceTests

- (void)testRangeSelection
{
    UTF8CharacterSequence *str = [UTF8CharacterSequence sequenceWithString:@"abcdefghijklmnopqrstuvwxyz"];

    UTF8CharacterSequence *str1 = [str subsequenceWithRange:NSMakeRange(0, 3)];
    UTF8CharacterSequence *str2 = [str subsequenceWithRange:NSMakeRange(23, 3)];

    XCTAssert([self sequenceIsEqualToString:str1 string:@"abc"]);
    XCTAssert([self sequenceIsEqualToString:str2 string:@"xyz"]);
}

- (void)testReversal
{
    UTF8CharacterSequence *str = [[UTF8CharacterSequence sequenceWithString:@"abcdefghijklmnopqrstuvwxyz"] reverse];
    NSString *reversed = @"zyxwvutsrqponmlkjihgfedcba";

    XCTAssert([self sequenceIsEqualToString:str string:reversed]);
}

- (BOOL)sequenceIsEqualToString:(UTF8CharacterSequence *)seq string:(NSString *)string
{
    NSString *str = [NSString stringWithCString:seq.sequence encoding:NSUTF8StringEncoding];

    return [str isEqualToString:string];
}

@end
