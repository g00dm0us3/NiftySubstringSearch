//
// Created by g00dm0us3 on 7/7/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUMBER_OF_ERRORS(alpha, length) ((NSUInteger)floorf(alpha*length))

@interface NSString (StringWithErrorLevel)

- (NSString *)stringWithErrorLevel:(float)errorLevel;

@end