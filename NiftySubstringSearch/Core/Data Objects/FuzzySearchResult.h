//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FuzzySearchResult : NSObject

@property (nonatomic, readonly) NSUInteger editDistance;
@property (nonatomic, readonly) NSUInteger position;

- (instancetype)init:(NSUInteger)editDistance position:(NSUInteger)position;

@end