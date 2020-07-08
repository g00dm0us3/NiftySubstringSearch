//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FuzzySearchResult;
@interface FuzzySubstringSearch : NSObject

- (instancetype)initWithString:(NSString *)string;
- (NSArray<FuzzySearchResult *> *)substring:(NSString *)string maxEditDistance:(NSUInteger)maxEditDistance;
- (NSValue *)resolveSuffixFor:(FuzzySearchResult *)searchResult substring:(NSString *)substring error:(NSError * _Nullable *)error;

@end
