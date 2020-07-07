//
//  UTF8CharacterSequence.h
//  NiftySubstringSearch
//
//  Created by g00dm0us3 on 6/28/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UTF8CharacterSequence : NSObject

@property (nonatomic) char *sequence;
@property (nonatomic) NSUInteger length;

+ (instancetype)sequenceWithString:(NSString *)string;

- (UTF8CharacterSequence *)subsequenceWithRange:(NSRange)range;
- (UTF8CharacterSequence *)reverse;


@end

NS_ASSUME_NONNULL_END
