//
// Created by g00dm0us3 on 7/7/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "NSString+EditDistanceDP.h"
#import "UTF8CharacterSequence.h"
#import "EditDistance.h"

@implementation NSString (EditDistanceDP)

- (NSUInteger)editDistanceDP:(NSString *)pattern
{
    UTF8CharacterSequence *textBuf = [UTF8CharacterSequence sequenceWithString:self];
    UTF8CharacterSequence *patternBuf = [UTF8CharacterSequence sequenceWithString:pattern];

    return [EditDistance editDistanceDP:textBuf textRange:NSMakeRange(0, textBuf.length) pattern:patternBuf];
}

@end
