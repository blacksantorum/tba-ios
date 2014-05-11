//
//  NSDictionary+CLT.h
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//
//  This category extends NSDictionary to return an instance
//  of NSDictionary with all NSNull values purged.
//
//  Objects initialized with the NSNull purged dictionarys
//  will have nil values for undefined properties

#import <Foundation/Foundation.h>

@interface NSDictionary (CLT)

- (NSDictionary *)dictionaryWithoutNullValues;

@end
