//
//  EditDistance.h
//  NiftySubstringSearch
//
//  Created by g00dm0us3 on 7/9/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UTF8CharacterSequence;
@interface EditDistance : NSObject

+ (NSInteger)fastEditDistance:(UTF8CharacterSequence *)text textRange:(NSRange)textRange pattern:(UTF8CharacterSequence *)pattern;
+ (NSUInteger)editDistanceDP:(UTF8CharacterSequence *)text textRange:(NSRange)textRange pattern:(UTF8CharacterSequence *)pattern;
+ (BOOL)internalEditDistanceUkkonen:(UTF8CharacterSequence *)text textRange:(NSRange)textRange pattern:(UTF8CharacterSequence *)pattern maxEditDistance:(NSInteger) maxEditDistance result:(NSInteger * _Nonnull)result;

@end

NS_ASSUME_NONNULL_END
