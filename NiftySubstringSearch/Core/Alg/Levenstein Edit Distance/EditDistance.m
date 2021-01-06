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

    uint32_t  dpMatrix[pattern.length+1][textLength+1];

    dpMatrix[0][0] = 0;
    for (uint32_t i = 1; i <= pattern.length; i++) {
        dpMatrix[i][0] = i;
    }

    for (uint32_t j = 1; j <= textLength; j++) {
        dpMatrix[0][j] = j;
    }

    int iterations = 0;
    for (int i = 1; i <= pattern.length; i++) {
        for (int j = 1; j <= textLength; j++) {
            dpMatrix[i][j] = MIN(dpMatrix[i-1][j] + 1,
                                 MIN(dpMatrix[i][j-1] + 1,
                                     dpMatrix[i-1][j-1] + CONDITIONAL_ONE(text.sequence[startLocation+j-1], pattern.sequence[i-1])));
            iterations++;
        }
    }
    
    NSLog(@"Iterations: %i", iterations);
    
    return dpMatrix[pattern.length][textLength];
}

// From Ukkonen "Approximate String Matching Algorithms". Works a lot faster, then naive, for long, almost similar texts.
// If texts are almost similar, then maxEditDistance can be low, which leads to low runtime (orders of magnitude, in fact). Runtime of alg O(t*min(n,m)), where t is max. edit dst.
+ (NSInteger)fastEditDistance:(UTF8CharacterSequence *)text textRange:(NSRange)textRange pattern:(UTF8CharacterSequence *)pattern {
    NSInteger res = 0;
    NSInteger editDistance = (NSInteger)fabsf((float)textRange.length - (float)pattern.length)+1;
    
    while (![EditDistance internalEditDistanceUkkonen:text textRange:textRange pattern:pattern maxEditDistance:editDistance result:&res]) {
        res = 0;
        editDistance *= 2;
    }
    
    return res;
}


+ (BOOL)internalEditDistanceUkkonen:(UTF8CharacterSequence *)text textRange:(NSRange)textRange pattern:(UTF8CharacterSequence *)pattern maxEditDistance:(NSInteger) maxEditDistance result:(NSInteger * _Nonnull)result {
    
    // n
    NSInteger textLength = textRange.length;
    
    // m
    NSInteger patternLength = pattern.length;
    
    if (maxEditDistance < fabsf((float)textLength - (float)patternLength)) {
        (*result) = -1;
        return false;
    }
    
    NSInteger p = (NSInteger)floor(0.5*(maxEditDistance - fabsf((float)textLength - (float)patternLength)));
    
    // storage
    // - TODO: get rid of this.
    uint32_t  dpMatrix[pattern.length+1][textLength+1];
    
    for (int i = 0; i <= patternLength; i++) {
        for (int j = 0; j <= textLength; j++){
            dpMatrix[i][j] = 2*maxEditDistance;
        }
    }

    dpMatrix[0][0] = 0;
    for (uint32_t i = 1; i <= pattern.length; i++) {
        dpMatrix[i][0] = i;
    }

    for (uint32_t j = 1; j <= textLength; j++) {
        dpMatrix[0][j] = j;
    }
    
    // - TODO: finish this
    uint32_t prevColumn[patternLength+1];
    uint32_t nextColumn[patternLength+1];
    
    NSUInteger startLocation = 0;//textRange.location;
    int iterations = 0;
    
    for (NSInteger i = 1; i <= patternLength; i++) {
        if (textLength >= patternLength) {
            
            for (NSInteger j = MAX(1, i - p); j <= MIN(textLength, i + (textLength-patternLength) + p); j++) {
                dpMatrix[i][j] = MIN(dpMatrix[i-1][j] + 1,
                                     MIN(dpMatrix[i][j-1] + 1,
                                         dpMatrix[i-1][j-1] + CONDITIONAL_ONE(text.sequence[startLocation+j-1], pattern.sequence[i-1])));
                iterations++;
                
            }
            
            continue;
        }

        for (NSInteger j = MAX(1, i + (textLength - patternLength) - p); j <= MIN(textLength, i + p); j++) {
            dpMatrix[i][j] = MIN(dpMatrix[i-1][j] + 1,
                                 MIN(dpMatrix[i][j-1] + 1,
                                     dpMatrix[i-1][j-1] + CONDITIONAL_ONE(text.sequence[startLocation+j-1], pattern.sequence[i-1])));
            iterations++;
        }
    }
    
    NSLog(@"Iterations: %i", iterations);
    
    if (dpMatrix[patternLength][textLength] <= maxEditDistance) {
        (*result) = dpMatrix[patternLength][textLength];
        return true;
    }
    
    
    (*result) = -1;
    
    return false;
}

@end
