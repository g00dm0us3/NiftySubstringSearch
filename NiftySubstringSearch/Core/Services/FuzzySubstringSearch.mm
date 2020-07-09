//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "FuzzySubstringSearch.h"
#import "UTF8CharacterSequence.h"
#import "FuzzySearchResult.h"

#import "EditDistance.h"

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
    if (substring.length == 0) {
        (*error) = [NSError errorWithDomain:@"SuffixResolution" code:1 userInfo:@{NSLocalizedFailureReasonErrorKey : @"String is empty"}];
        return nil;
    }

    UTF8CharacterSequence *patternBuf = [UTF8CharacterSequence sequenceWithString:substring];

    NSUInteger loc = searchResult.position;
    NSUInteger targetDistance = searchResult.editDistance;
    NSUInteger minSuffixLength = substring.length - searchResult.editDistance;
    NSUInteger maxSuffixLength = substring.length + searchResult.editDistance;
    
    for (NSUInteger l = minSuffixLength; l <= maxSuffixLength; l++) {
        NSUInteger location = loc - l + 1;
        NSRange rng = NSMakeRange(location, l);
        NSUInteger dst = [EditDistance editDistanceDP:text textRange:rng pattern:patternBuf];

        if (dst <= targetDistance) {
            return [NSValue valueWithRange:rng];
        }
    }

    (*error) = [NSError errorWithDomain:@"SuffixResolution" code:2 userInfo:
            @{NSLocalizedDescriptionKey:@"Suffix could not be resolved because the specified substring doesn't appear it the given search position in the text."
                                        "Make sure, that you are passing the same substring, which was used to obtain the searchResult."}];

    return nil;
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
