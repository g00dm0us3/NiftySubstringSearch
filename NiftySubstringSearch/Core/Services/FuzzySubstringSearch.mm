//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "FuzzySubstringSearch.h"
#import "UTF8CharacterSequence.h"
#import "FuzzySearchResult.h"

#include "MyersFastApproximateStringMatchingAlg.h"


@interface FuzzySubstringSearch ()
{
    UTF8CharacterSequence *text;
}
@end

@implementation FuzzySubstringSearch

#pragma mark - Public Interface

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];

    if (self) {
        if (string.length == 0) {
            return nil;
        }
        text = [UTF8CharacterSequence sequenceWithString:string];
    }

    return self;
}

- (NSArray<FuzzySearchResult *> *)substring:(NSString *)string maxEditDistance:(NSUInteger)maxEditDistance
{
    UTF8CharacterSequence *cSubstring = [UTF8CharacterSequence sequenceWithString:string];

    return [self find:cSubstring maxEditDistance:maxEditDistance];
}

- (NSValue *)resolveSuffixFor:(FuzzySearchResult *)searchResult substring:(NSString *)substring error:(NSError * _Nullable *)error
{
    ///- TODO:rewrite
    if (substring.length == 0) {
        (*error) = [NSError errorWithDomain:@"RangeResolution" code:1 userInfo:@{NSLocalizedFailureReasonErrorKey : @"String is empty"}];
        return nil;
    }
    
    UTF8CharacterSequence *reversed = [[UTF8CharacterSequence sequenceWithString:substring] reverse];
    NSUInteger loc = searchResult.position;
    NSUInteger start = 0;
    NSUInteger len = loc - start + 1;

    UTF8CharacterSequence *reversedChunk = [[text subsequenceWithRange:NSMakeRange(start, len)] reverse];

    FuzzySubstringSearch *search = [[FuzzySubstringSearch alloc] initWithSeq:reversedChunk];
    NSArray<FuzzySearchResult *> *results = [search find:reversed maxEditDistance:searchResult.editDistance];

    if (results.count == 0) {
        (*error) = [NSError errorWithDomain:@"RangeResolution" code:2 userInfo:@{NSLocalizedFailureReasonErrorKey : @"String not found"}];
        return nil;
    }

    NSLog(@"%s", reversedChunk.sequence);
    
    NSUInteger minLength = ULONG_MAX;
    NSUInteger resultingIndex = ULONG_MAX;

    for (FuzzySearchResult *res in results) {
        if (res.editDistance < searchResult.editDistance) continue;
        
        NSUInteger startingPosition = ((reversedChunk.length - 1) - res.position) + start;
        NSUInteger length = loc - startingPosition + 1;
        
        
        if (length < minLength) {
            minLength = length;
            resultingIndex = startingPosition;
        }
    }

    NSRange result = NSMakeRange(resultingIndex, minLength);

    return [NSValue valueWithRange:result];
}

#pragma mark - Private Interface

- (instancetype)initWithSeq:(UTF8CharacterSequence *)seq
{
    self = [super init];

    if (self) {
        text = seq;
    }

    return self;
}

- (NSArray<FuzzySearchResult *> *)find:(UTF8CharacterSequence *)sequence maxEditDistance:(NSUInteger)maxEditDistance
{
    if (sequence.length == 0) {
        return nil;
    }
    
    maxEditDistance = MIN(maxEditDistance, sequence.length);

    MyersFastApproximateStringMatchingAlg *matchingAlg = new MyersFastApproximateStringMatchingAlg(sequence.sequence, static_cast<uint32_t>(sequence.length));

    std::forward_list<SearchResult> *algResult = matchingAlg->findPatternInText(text.sequence, (uint32_t)text.length, (uint32_t)maxEditDistance);

    if (algResult == NULL || algResult->empty()) {
        return nil;
    }

    NSMutableArray<FuzzySearchResult *> *result = [NSMutableArray new];

    for(auto it = algResult->begin(); it != algResult->end(); it++) {
        SearchResult res = (*it);
        FuzzySearchResult *wrapper = [[FuzzySearchResult alloc] init:res.distance position:res.position];
        [result addObject:wrapper];
    }

    delete algResult;

    return result;
}




@end
