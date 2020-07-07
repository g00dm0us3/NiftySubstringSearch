//
// Created by g00dm0us3 on 7/7/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "NSString+StringWithErrorLevel.h"
#import "UTF8CharacterSequence.h"
#import "NSArray+SelectRandomElements.h"


@implementation NSString (StringWithErrorLevel)

// errorLevel ∈ [0,1]
- (NSString *)stringWithErrorLevel:(float)errorLevel
{
    if (errorLevel < 0 || errorLevel > 1) return nil;

    UTF8CharacterSequence *sequence = [UTF8CharacterSequence sequenceWithString:self];
    NSUInteger numberOfErrors = NUMBER_OF_ERRORS(errorLevel, sequence.length);

    if (numberOfErrors == 0) return self;

    NSMutableArray<NSNumber *> *indicies = [NSMutableArray array];

    for (NSUInteger i = 0; i < sequence.length; i++) {
        [indicies addObject:@(i)];
    }

    NSMutableArray<NSNumber *> *selectedIndicies = [NSMutableArray arrayWithArray:[indicies selectRandomElements:numberOfErrors]];

    [selectedIndicies sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSUInteger num1 = (NSUInteger)((NSNumber *)obj1).integerValue;
        NSUInteger num2 = (NSUInteger)((NSNumber *)obj2).integerValue;
        return num1 < num2 ? NSOrderedAscending : num1 > num2 ? NSOrderedDescending : NSOrderedSame;
    }];

    char *arr = sequence.sequence;

    NSMutableDictionary<NSNumber *, NSMutableString *> *charByIndex = [NSMutableDictionary dictionary];

    for (NSUInteger i = 0; i < numberOfErrors; i++) {
        NSUInteger index = (NSUInteger) selectedIndicies[i].integerValue;

        uint32 action = arc4random_uniform(2);

        if (action == 0) {
            arr[index] = '~'; // delete
        } else {
            charByIndex[selectedIndicies[i]] = [NSMutableString stringWithFormat:@"%c|", arr[index]]; // insert
        }
    }

    NSMutableString *result = [NSMutableString stringWithCString:arr encoding:NSUTF8StringEncoding];

    NSMutableArray<NSNumber *> *reverseSorted = [NSMutableArray arrayWithArray:charByIndex.allKeys];
    [reverseSorted sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSUInteger num1 = (NSUInteger)((NSNumber *)obj1).integerValue;
        NSUInteger num2 = (NSUInteger)((NSNumber *)obj2).integerValue;
        return num1 > num2 ? NSOrderedAscending : num1 < num2 ? NSOrderedDescending : NSOrderedSame;
    }];

    for(NSNumber *idx in reverseSorted) {
        NSMutableString *replacement = charByIndex[idx];
        NSUInteger loc = (NSUInteger) idx.integerValue;
        [replacement replaceOccurrencesOfString:@"|" withString:@"r" options:0 range:NSMakeRange(0, 2)];
        [result replaceCharactersInRange:NSMakeRange(loc, 1) withString:replacement];
    }

    [result replaceOccurrencesOfString:@"~" withString:@"" options:0 range:NSMakeRange(0, result.length)];

    return result;
}

@end