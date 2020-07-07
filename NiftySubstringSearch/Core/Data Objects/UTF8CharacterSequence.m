//
//  UTF8CharacterSequence.m
//  NiftySubstringSearch
//
//  Created by g00dm0us3 on 6/28/20.
//  Copyright © 2020 g00dm0us3. All rights reserved.
//

#import "UTF8CharacterSequence.h"

@interface UTF8CharacterSequence ()
{
    char *byteArray;
}
@end

@implementation UTF8CharacterSequence

- (instancetype)init
{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not implemented" userInfo:nil] raise];
    return nil;
}

+ (instancetype)sequenceWithString:(NSString *)string
{
    return [[UTF8CharacterSequence alloc] initWithString:string];
}
- (instancetype)initWithString:(NSString *)string
{
    self = [super init];

    if (self) {
        BOOL canBeConverted = [string canBeConvertedToEncoding:NSUTF8StringEncoding];

        if (!canBeConverted) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Provided nsstring cannot be coverted to UTF-8 sequence, loslessly." userInfo:nil]raise];
        }

        _length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        NSUInteger bufferLength = _length + 1;

        byteArray = (char *)malloc(bufferLength*sizeof(char));

        [string getCString:byteArray maxLength:bufferLength encoding:NSUTF8StringEncoding];

        _sequence = byteArray;

    }

    return self;
}

- (instancetype)initWithBuf:(char *)buf length:(NSUInteger)length
{
    self = [super init];

    if (self) {
        _sequence = buf;
        _length = length;
    }

    return self;
}

- (UTF8CharacterSequence *)subsequenceWithRange:(NSRange)range
{
    NSUInteger loc = range.location;
    NSUInteger len = range.length;

    if (loc+len > self.length) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Range out of range... Yeah" userInfo:nil] raise];
    }

    char *res =[self allocCharBuf:len];

    for (NSUInteger i = 0; i < len; i++) {
        res[i] = self.sequence[i+loc];
    }

    res[len] = 0;

    return [[UTF8CharacterSequence  alloc] initWithBuf:res length:len];
}

- (UTF8CharacterSequence *)reverse
{
    char *res = [self allocCharBuf:self.length];

    for (NSUInteger i = 0; i <= self.length-1; i++) {
        res[i] = self.sequence[self.length-1-i];
    }

    res[self.length] = 0;

    return [[UTF8CharacterSequence alloc] initWithBuf:res length:self.length];
}

- (char *)allocCharBuf:(NSUInteger)length
{
    return (char *)malloc(sizeof(char)*(length+1));
}

- (void)dealloc
{
    free(byteArray);
}

@end
