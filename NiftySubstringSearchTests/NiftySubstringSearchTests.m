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
        int j = 1;
        for (FuzzySearchResult *res in result) {
            XCTAssert(res.editDistance == 1, @"Wrong edit distance!");
            XCTAssert(res.position == j++, @"Wrong position!");
        }
    }
}

- (void)testRangeResolutionExactMatch
{
    NSString *text = @"abcdefghijklmnopqrstuvwxyz";
    NSArray<NSString *> *patterns = @[@"abc", @"xyz", @"ijk"];
    
    FuzzySubstringSearch *search = [[FuzzySubstringSearch alloc] initWithString:text];
    
    for (NSString *p1 in patterns) {
        NSArray<FuzzySearchResult *> *matches = [search substring:p1 maxEditDistance:0];
        XCTAssert(matches.count > 0, @"There should be a match!");
    
        NSError *error = nil;
        NSValue *possiblyWrong = [search resolveSuffixFor:matches[0] substring:p1 error:&error];
    
        XCTAssert(error == nil, @"There shouldn't be any error!");
    
        NSString *resStr = [text substringWithRange:possiblyWrong.rangeValue];
        XCTAssert([resStr isEqualToString:p1], @"Strings not equal!");
    }
}

- (void)testRangeResolutionFuzzyMatch
{
    NSString *text = @"aabcdefghijjklmnopqrstuvwxyyz";
    NSArray<NSString *> *patterns = @[@"abc",@"xyz", @"ijk"];
    
    FuzzySubstringSearch *search = [[FuzzySubstringSearch alloc] initWithString:text];
    
    for (NSString *p1 in patterns) {
        NSArray<FuzzySearchResult *> *matches = [search substring:p1 maxEditDistance:1];
        XCTAssert(matches.count > 0, @"There should be a match!");
    
        for(FuzzySearchResult *match in matches)
        {
            NSError *error = nil;
            NSValue *possiblyWrong = [search resolveSuffixFor:match substring:p1 error:&error];
               
            XCTAssert(error == nil, @"There shouldn't be any error!");

            NSString *resStr = [text substringWithRange:possiblyWrong.rangeValue];
            XCTAssert([resStr editDistanceDP:p1] <= 1, @"Wrong edit distance");

            NSLog(@"%@", resStr);
        }
    }
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
        NSString *maimed = sample;
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
        NSString *maimed = sample;//[sample stringWithErrorLevel:alpha];
        /// - TODO: edit distance in the string, as it doesn't always correspond, which results in empty search
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
        uint32_t randChar = arc4random_uniform(25);
        charBuf[i] = alphabet[randChar];
    }

    NSString *result =  [NSString stringWithCString:charBuf encoding:NSUTF8StringEncoding];
    free(charBuf);

    return result;
}

@end
