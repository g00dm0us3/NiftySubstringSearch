//
// Created by g00dm0us3 on 7/7/20.
// Copyright (c) 2020 g00dm0us3. All rights reserved.
//

#import "NSArray+SelectRandomElements.h"


@implementation NSArray (SelectRandomElements)

- (NSArray*)selectRandomElements:(NSUInteger)count
{
    NSMutableDictionary<NSNumber *, NSNumber *> *taken = [NSMutableDictionary dictionary];
    NSMutableArray<NSNumber *> *result = [NSMutableArray array];

    for (NSUInteger i = self.count-1, j = 0; i >= 0 && j < count; i--, j++) {
        NSNumber *rand = @(arc4random_uniform((uint32_t)i));
        NSNumber *pointerBoxed = @(i);

        NSNumber *toAdd = self[rand.unsignedIntegerValue];
        if (taken[rand]) {
            toAdd = taken[rand];
        }

        // record swap with the last
        taken[rand] = self[i];

        if (taken[pointerBoxed]) { // if the last happens to be swapped
            taken[rand] = taken[pointerBoxed]; // resolve that
            [taken removeObjectForKey:pointerBoxed]; // delete swap
        }

        [result addObject:toAdd];
    }

    return result;
}

@end