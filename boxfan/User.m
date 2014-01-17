//
//  User.m
//  boxfan
//
//  Created by Chris Tibbs on 12/16/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import "User.h"
#import "Auth.h"

@implementation User

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _handle = [dictionary objectForKey:@"screen_name"];
        _name = [dictionary objectForKey:@"name"];
        _profileImageURL = [dictionary objectForKey:@"profile_image_url"];
        _twitterID = [dictionary objectForKey:@"id"];
    }
    
    return self;
}

-(instancetype)initWithListOfUsersDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _handle = [dictionary objectForKey:@"screen_name"];
        _name = [dictionary objectForKey:@"name"];
        _profileImageURL = [dictionary objectForKey:@"img"];
        _userID = [dictionary objectForKey:@"id"];
        _points = (int)[dictionary objectForKey:@"points"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.handle forKey:@"handle"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.profileImageURL forKey:@"profileImageURL"];
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.twitterID forKey:@"twitterID"];
}

-(instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _handle = [decoder decodeObjectForKey:@"handle"];
        _name = [decoder decodeObjectForKey:@"name"];
        _profileImageURL = [decoder decodeObjectForKey:@"profileImageURL"];
        _userID = [decoder decodeObjectForKey:@"userID"];
        _twitterID = [decoder decodeObjectForKey:@"twitterID"];
    }
    
    return self;
}

-(NSDictionary *)userDictionaryForSignIn
{
    return @{@"screen_name" : self.handle, @"name" : self.name, @"profile_image_url" : self.profileImageURL, @"id": self.twitterID, @"password" : [Auth encryptedKeyForUser:self]};
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@ %@",self.userID,self.handle,self.name,self.profileImageURL];
}

-(NSString *)titleForGodsView
{
    return [NSString stringWithFormat:@"%@ (%d)",self.handle,self.points];
}

@end
