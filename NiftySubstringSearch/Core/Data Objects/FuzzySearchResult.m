//
// Created by g00dm0us3 on 6/28/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "FuzzySearchResult.h"


@implementation FuzzySearchResult

- (instancetype)init:(NSUInteger)editDistance position:(NSUInteger)position
{
    self = [super init];

    if (self) {
        _editDistance = editDistance;
        _position = position;
    }

    return self;
}

@end