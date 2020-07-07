//
// Created by g00dm0us3 on 7/7/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "NSString+EditDistanceDP.h"
#import "UTF8CharacterSequence.h"

#define CONDITIONAL_ONE(a,b) (a == b ? 0 : 1)

@implementation NSString (EditDistanceDP)

- (NSUInteger)editDistanceDP:(NSString *)pattern
{
    UTF8CharacterSequence *textBuf = [UTF8CharacterSequence sequenceWithString:self];
    UTF8CharacterSequence *patternBuf = [UTF8CharacterSequence sequenceWithString:pattern];

    if (textBuf.length == 0 || patternBuf.length == 0) {
        return MAX(textBuf.length, patternBuf.length);
    }

    // 4 bytes * (2*10^7) ~ 80 MB, also account for the run time - grows as O(m*n) (~10^7)
    if (textBuf.length*patternBuf.length >= 2E8) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Out of ... I forgot the name of that thing. We are out of some important thing!" userInfo:nil] raise];
    }

    uint32  dpMatrix[patternBuf.length+1][textBuf.length+1]; // holy shit

    dpMatrix[0][0] = 0;
    for (uint32 i = 1; i <= patternBuf.length; i++) {
        dpMatrix[i][0] = i;
    }

    for (uint32 j = 1; j <= textBuf.length; j++) {
        dpMatrix[0][j] = j;
    }

    for (int i = 1; i <= patternBuf.length; i++) {
        for (int j = 1; j <= textBuf.length; j++) {
            dpMatrix[i][j] = MIN(dpMatrix[i-1][j]+1, MIN(dpMatrix[i][j-1]+1, dpMatrix[i-1][j-1]+CONDITIONAL_ONE(textBuf.sequence[j-1], patternBuf.sequence[i-1])));
        }
    }

    return dpMatrix[patternBuf.length][textBuf.length];
}

@end