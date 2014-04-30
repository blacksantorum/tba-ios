//
//  Auth.m
//  boxfan
//
//  Created by Chris Tibbs on 1/11/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "Auth.h"

@interface Auth ()

+(NSString *)encryptWithHash:(NSString *)string;

@end

@implementation Auth

+(NSString *)encryptWithHash:(NSString *)string
{
    NSDictionary *superSecretHash = @{@"f":@"9",@"x":@"k",@"k":@"1",@"o":@"5",@"m":@"f",@"w":@"x",@"u":@"d",@"b":@"w",@"z":@"7",@"a":@"r",@"v":@"2",@"i":@"v",@"y":@"z",@"e":@"u",@"c":@"h",@"d":@"t",@"h":@"s",@"q":@"i",@"j":@"g",@"p":@"e",@"r":@"p",@"s":@"6",@"g":@"o",@"t":@"q",@"n":@"a",@"l":@"b",@"0":@"3",@"1":@"4",@"2":@"m",@"3":@"j",@"4":@"8",@"5":@"c",@"6":@"0",@"7":@"y",@"8":@"n",@"9":@"l",@"_":@"_"};
    
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    for (int i=0; i < [string length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
        [characters addObject:ichar];
    }
    
    NSString *encryptedString = [[NSString alloc] init];
    
    for (NSString *character in characters) {
        encryptedString = [encryptedString stringByAppendingString:[superSecretHash valueForKey:character]];
    }
    
    return encryptedString;
}

+(NSString *)encryptedKeyForUser:(User *)user
{
    NSString *key = [[NSString alloc] init];
    
    key = [user.handle lowercaseString];
    key = [Auth encryptWithHash:key];
    
    return key;
}

+(NSString *)sessionToken
{
    NSString *token = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"Token"]) {
        token = [defaults objectForKey:@"Token"];
    }
    NSLog(@"%@",token);
    return token;
}

@end
