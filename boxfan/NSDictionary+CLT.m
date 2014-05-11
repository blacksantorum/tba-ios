//
//  NSDictionary+CLT.m
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "NSDictionary+CLT.h"

@implementation NSDictionary (CLT)

- (NSDictionary *)dictionaryWithoutNullValues
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (id key in self) {
        if ([self objectForKey:key] != (id)[NSNull null]) {
            [dictionary setObject:[self objectForKey:key] forKey:key];
        }
    }
    return dictionary;
}

@end
