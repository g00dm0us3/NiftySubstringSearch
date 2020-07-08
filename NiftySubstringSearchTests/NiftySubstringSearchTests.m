//
//  NiftySubstringSearchTests.m
//  NiftySubstringSearchTests
//
//  Created by g00dm0us3 on 6/28/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FuzzySubstringSearch.h"
#import "FuzzySearchResult.h"
#import "UTF8CharacterSequence.h"

#import "NSString+EditDistanceDP.h"
#import "NSArray+SelectRandomElements.h"
#import "NSString+StringWithErrorLevel.h"

@interface NiftySubstringSearchTests : XCTestCase

@end

@implementation NiftySubstringSearchTests

- (void)testShortBasicSearch
{
    FuzzySubstringSearch *srch = [[FuzzySubstringSearch alloc] initWithString:@"ACTGA"];

    for (int i = 0; i < 100; i++) {
        NSArray<FuzzySearchResult *> *result = [srch substring:@"TC" maxEditDistance:1];
        int i = 1;
        for (FuzzySearchResult *res in result) {
            XCTAssert(res.editDistance == 1, @"Wrong edit distance!");
            XCTAssert(res.position == i++, @"Wrong position!");
        }
    }
}

- (void)testRangeResolution
{
    /// - TODO: write, it.
}

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

static char alphabet[26]  = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','p','q','r','s','t','u','v','w','x','y','z'};

- (void)testFalsePositiveRateRandomText
{
    NSString *str = [self generateRandomText:1000000];
    NSString *sample = [str substringWithRange:NSMakeRange(500, 500)];

    int hits[11];
    FuzzySubstringSearch *search = [[FuzzySubstringSearch alloc] initWithString:str];
    for (int i = 0; i < 11; i++) {
        float alpha = i/10.0f;
        NSString *maimed = [sample stringWithErrorLevel:alpha];
        NSArray<FuzzySearchResult *> *result = [search substring:maimed maxEditDistance:(NSUInteger)floor(alpha*(maimed.length-1))];
        hits[i] = (int)result.count;
    }

    for (int i = 0; i < 11; i++) {
        NSLog(@"%f, %i, %f", i/10.0, hits[i], log10(hits[i]));
    }
}

- (void)testFalsePositiveRateMobydickText
{
    NSString *str = [self loadTextFile:@"mobydick"];
    NSString *sample = [str substringWithRange:NSMakeRange(500000, 500)];

    NSLog(@"String length: %lu", str.length);

    int hits[11];
    FuzzySubstringSearch *search = [[FuzzySubstringSearch alloc] initWithString:str];
    for (int i = 0; i < 11; i += 1) {
        float alpha = i/10.0f;
        NSString *maimed = [sample stringWithErrorLevel:alpha];
        /// - TODO: return edit distance in the string, as it doesn't always correspond, which results in empty search
        NSArray<FuzzySearchResult *> *result = [search substring:maimed maxEditDistance:(NSUInteger)ceil(alpha*(maimed.length))];
        hits[i] = (int)result.count;
    }

    for (int i = 0; i < 11; i++) {
        NSLog(@"%f, %i, %f", i/10.0, hits[i], log10(hits[i]));
    }
}

- (void)testFalsePositiveRateCatcher
{
    NSString *str = [self loadTextFile:@"catcher"];
    NSString *sample = [str substringWithRange:NSMakeRange(5000, 500)];

    NSLog(@"String length: %lu", str.length);

    int hits[11];
    FuzzySubstringSearch *search = [[FuzzySubstringSearch alloc] initWithString:str];
    for (int i = 0; i < 11; i++) {
        float alpha = i/10.0f;
        NSString *maimed = [sample stringWithErrorLevel:alpha];
        NSArray<FuzzySearchResult *> *result = [search substring:maimed maxEditDistance:(NSUInteger)floor(alpha*(maimed.length))];
        hits[i] = (int)result.count;
    }

    for (int i = 0; i < 11; i++) {
        NSLog(@"%f, %i, %f", i/10.0, hits[i], log10(hits[i]));
    }
}

- (NSString *)loadTextFile:(NSString *)fileName
{
    NSString* path = [[NSBundle bundleForClass:[NiftySubstringSearchTests class]] pathForResource:fileName
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

    UTF8CharacterSequence *buf = [UTF8CharacterSequence sequenceWithString:[content lowercaseString]];
    NSMutableString *result = [NSMutableString string];
    NSSet<NSString *> *acceptableChar = [[NSSet alloc] initWithArray:@[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"]];

    for (int i = 0; i < buf.length; i++) {
        char c = buf.sequence[i];
        NSString *str = [NSString stringWithFormat:@"%c", c];
        if (![acceptableChar containsObject:str]) continue;
        [result appendString:str];
    }

    return result;
}

- (NSString *)generateRandomText:(NSUInteger)length
{
    char *charBuf = (char *)malloc((length+1)*sizeof(char));
    charBuf[length] = 0;

    for (int i = 0; i < length; i++) {
        uint32 randChar = arc4random_uniform(25);
        charBuf[i] = alphabet[randChar];
    }

    NSString *result =  [NSString stringWithCString:charBuf encoding:NSUTF8StringEncoding];
    free(charBuf);

    return result;
}

@end
