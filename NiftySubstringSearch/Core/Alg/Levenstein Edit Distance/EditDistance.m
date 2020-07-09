//
//  EditDistance.m
//  NiftySubstringSearch
//
//  Created by g00dm0us3 on 7/9/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import "EditDistance.h"
#import "UTF8CharacterSequence.h"

#define CONDITIONAL_ONE(a,b) (a == b ? 0 : 1)

@implementation EditDistance

// - TODO: use Ukkonen's trick to minimize runtime down to O(k⋅min(m,n)) (article: Ukkonen "Approximate String Matching Algorithms")
+ (NSUInteger)editDistanceDP:(UTF8CharacterSequence *)text textRange:(NSRange)textRange pattern:(UTF8CharacterSequence *)pattern
{
    if (text.length < textRange.location+textRange.length) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:
          [NSString stringWithFormat:@"Provided range [%lu...%lu] is invalid for the string with range [0...%lu]", textRange.location, textRange.length, text.length] userInfo:nil]
         raise];
    }
    
    NSUInteger textLength = textRange.length;
    NSUInteger startLocation = textRange.location;
    
    if (textLength == 0 || pattern.length == 0) {
        return MAX(textLength, pattern.length);
    }

    // 4 bytes * (2*10^7) ~ 80 MB, also account for the run time - grows as O(m*n) (~10^7)
    if (textLength*pattern.length >= 2E8) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Out of ... I forgot the name of that thing. We are out of some important thing!" userInfo:nil] raise];
    }

    uint32  dpMatrix[pattern.length+1][textLength+1]; // holy shit

    dpMatrix[0][0] = 0;
    for (uint32 i = 1; i <= pattern.length; i++) {
        dpMatrix[i][0] = i;
    }

    for (uint32 j = 1; j <= textLength; j++) {
        dpMatrix[0][j] = j;
    }

    for (int i = 1; i <= pattern.length; i++) {
        for (int j = 1; j <= textLength; j++) {
            dpMatrix[i][j] = MIN(dpMatrix[i-1][j] + 1,
                                 MIN(dpMatrix[i][j-1] + 1,
                                     dpMatrix[i-1][j-1] + CONDITIONAL_ONE(text.sequence[startLocation+j-1], pattern.sequence[i-1])));
        }
    }
    
    return dpMatrix[pattern.length][textLength];
}

@end
