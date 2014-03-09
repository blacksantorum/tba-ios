//
//  URLS.h
//  boxfan
//
//  Created by Chris Tibbs on 1/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fight.h"
#import "Comment.h"




@interface URLS : NSObject

+ (NSString *)appendSessionToken:(NSString *)urlString;

+ (NSString *)urlStringForPostingPickForFight:(Fight *)fight;
+ (NSString *)urlStringForPostingDecisionForFight:(Fight *)fight;
+ (NSString *)urlStringForPostingCommentForFight:(Fight *)fight;
+ (NSString *)urlStringForJabbingComment:(Comment *)comment;
+ (NSString *)urlStringForUnjabbingComment:(Comment *)comment;
+ (NSString *)urlStringForUpdatingProfileForUser:(User *)user;
+ (NSString *)urlStringForRailsSignIn;
+ (NSString *)urlStringForUsersTwitterWithScreenname:(NSString *)screenname;
+ (NSString *)urlForUsersCurrentPickForFight:(Fight *)Fight;
+ (NSString *)urlForUsersCurrentDecisionForFight:(Fight *)fight;
+ (NSString *)urlStringForUpdatingFOYtoFight:(Fight *)fight;

+ (NSURL *)urlForFeed;
+ (NSURL *)urlForUpcomingFights;
+ (NSURL *)urlForRecentFights;
+ (NSURL *)urlForUsers;
+ (NSURL *)urlForPicksOfUser:(User *)user;
+ (NSURL *)urlForGods;
+ (NSURL *)baseURL;
+ (NSURL *)urlForCommentsForFight:(Fight *)fight;
+ (NSURL *)urlForTwitterAuth;
+ (NSURL *)urlForTBATwitterAuth;

+ (BOOL)prod;

@end
