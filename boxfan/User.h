//
//  User.h
//  boxfan
//
//  Created by Chris Tibbs on 12/16/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fight.h"

@interface User : NSObject

@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *handle;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *profileImageURL;
@property (nonatomic,strong) NSString *twitterID;
@property (nonatomic,strong) Fight *foy;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithListOfUsersDictionary:(NSDictionary *)dictionary;

// encoding
-(void)encodeWithCoder:(NSCoder *)encoder;
-(instancetype)initWithCoder:(NSCoder *)decoder;
- (BOOL)isEqualToUser:(User *)user;

-(NSDictionary *)userDictionaryForSignIn;

+ (User *)getCurrentUser;

@end
