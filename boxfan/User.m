//
//  User.m
//  boxfan
//
//  Created by Chris Tibbs on 12/16/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import "User.h"
#import "Auth.h"
#import "TBARailsClient.h"

@implementation User

- (void)setIsLoggedIn:(BOOL)isLoggedIn
{
    _isLoggedIn = isLoggedIn;
    if (isLoggedIn) {
        if ([self.delegate respondsToSelector:@selector(currentUserLoggedin)]) {
            [self.delegate currentUserLoggedin];
        }
    }
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _handle = [dictionary objectForKey:@"screen_name"];
        _name = [dictionary objectForKey:@"name"];
        _profileImageURL = [dictionary objectForKey:@"profile_image_url"];
        _twitterID = [dictionary objectForKey:@"id"];
        NSDictionary *foyDict = [dictionary objectForKey:@"foy"];
        if (![JSONDataNullCheck isNull:foyDict]) {
            _foy = [[Fight alloc] initWithDictionary:foyDict];
        }
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
    [encoder encodeObject:self.sessionToken forKey:@"sessionToken"];
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
        _sessionToken = [decoder decodeObjectForKey:@"sessionToken"];
    }
    
    return self;
}

-(NSDictionary *)userDictionaryForSignIn
{
    return @{@"screen_name" : self.handle, @"name" : self.name, @"profile_image_url" : self.profileImageURL, @"id": self.twitterID, @"password" : [Auth encryptedKeyForUser:self]};
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@" ,self.userID,self.handle,self.name,self.profileImageURL,self.twitterID];
}

- (BOOL)isEqualToUser:(User *)user
{
    return [[self.handle lowercaseString] isEqualToString:[user.handle lowercaseString]];
}

+ (User *)getCurrentUser
{
    static User *currentUser = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentUser = [[self alloc] init];
    });
    
    return currentUser;
}

- (void)updateWithTwitterResponse:(NSDictionary *)response
{
    _handle = [response objectForKey:@"screen_name"];
    _name = [response objectForKey:@"name"];
    _profileImageURL = [response objectForKey:@"profile_image_url"];
    _twitterID = [response objectForKey:@"id"];
}

-(void)signInWithBackend
{
    [TBARailsClient sharedClient].delegate = self;
    NSDictionary *userDictionary = @{@"screen_name" : self.handle, @"name" : self.name, @"profile_image_url" : self.profileImageURL, @"id": self.twitterID, @"password" : [Auth encryptedKeyForUser:self]};
    [[TBARailsClient sharedClient] signInWithBackend:userDictionary];
}

-(void)saveCurrrentUserInDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:[User getCurrentUser]];
    [defaults setObject:encodedUser forKey:@"User"];
    [defaults synchronize];
}

- (void)updateCurrentUserWithEncodedUser:(NSData *)encodedUser
{
    User *currentUser = [User getCurrentUser];
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
    currentUser.handle = user.handle;
    currentUser.name = user.name;
    currentUser.profileImageURL = user.profileImageURL;
    currentUser.userID = user.userID;
    currentUser.twitterID = user.twitterID;
    currentUser.sessionToken = user.sessionToken;
}

#pragma mark - TBARailsClient Delegate Methods

- (void)TBARailsClient:(TBARailsClient *)client didLoginUser:(id)user
{
    NSLog(@"Returned user: %@", user);
    _userID = [user valueForKeyPath:@"user.id"];
    _sessionToken = [user valueForKeyPath:@"user.session_token"];
    [self saveCurrrentUserInDefaults];
    self.isLoggedIn = YES;
}

- (void)TBARailsClient:(TBARailsClient *)client didFailToLogin:(NSError *)error
{
    NSLog(@"User error block: %@",error.localizedDescription);
}

@end
