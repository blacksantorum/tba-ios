//
//  URLS.m
//  boxfan
//
//  Created by Chris Tibbs on 1/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "URLS.h"
#import "boxfanAppDelegate.h"

@interface URLS ()

@end

@implementation URLS


+(NSString *)appendSessionToken:(NSString *)urlString
{
    return [urlString stringByAppendingString:[NSString stringWithFormat:@"?session_token=%@",[Auth sessionToken]]];
}

+(NSString *)appendSessionTokenForGods:(NSString *)urlString
{
    return [urlString stringByAppendingString:[NSString stringWithFormat:@"&session_token=%@",[Auth sessionToken]]];
}

+(BOOL)prod
{
    boxfanAppDelegate *appDelegate = (boxfanAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.prod;
}

+ (NSString *)urlStringForGettingPlaces
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/places", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL]];
}

+ (NSString *)urlStringForPostingPlace:(Place *)place
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/places", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL]];
}

+(NSString *)urlStringForPostingPickForFight:(Fight *)fight
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@/picks", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,fight.fightID.description]];
}

+(NSString *)urlStringForPostingDecisionForFight:(Fight *)fight
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@/decisions", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,fight.fightID.description]];
}

+ (NSString *)urlStringForJabbingComment:(Comment *)comment
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/comments/%ld/like", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,(long)comment.commentID]];
}

+ (NSString *)urlStringForUnjabbingComment:(Comment *)comment
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/comments/%ld/unlike", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,(long)comment.commentID]];
}

+ (NSString *)urlStringForDeletingComment:(Comment *)comment
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/comments/%d",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,comment.commentID]];
}

+ (NSString *)urlStringForPostingCommentForFight:(Fight *)fight
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@/comments", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,fight.fightID.description]];
}

+ (NSString *)urlStringForUpdatingProfileForUser:(User *)user
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/users/%@", [URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,user.userID.description]];
}

+(NSString *)urlStringForRailsSignIn
{
    return [NSString stringWithFormat:@"%@/signin",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL];
}

+ (NSString *)urlStringForUsersTwitterWithScreenname:(NSString *)screenname
{
    return  [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", screenname];
}

+ (NSString *)urlStringForUpdatingFOYtoFight:(Fight *)fight
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@/foy",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL ,fight.fightID.description]];
}

+ (NSURL *)urlForUpcomingFights
{
    return [NSURL URLWithString:[URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/future",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL]]];
}

+ (NSURL *)urlForRecentFights
{
    return [NSURL URLWithString:[URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/past",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL]]];
}

+ (NSString *)urlForUsersCurrentPickForFight:(Fight *)fight
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL ,fight.fightID.description]];
}

+ (NSString *)urlForUsersCurrentDecisionForFight:(Fight *)fight
{
    return [URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL ,fight.fightID.description]];
}

+ (NSURL *)urlForUsers
{
    return [NSURL URLWithString:[URLS appendSessionToken:[NSString stringWithFormat:@"%@/users",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL]]];
}

+ (NSURL *)urlForPicksOfUser:(User *)user
{
    return [NSURL URLWithString:[URLS appendSessionToken:[NSString stringWithFormat:@"%@/users/%@",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,user.userID.description]]];
}

+ (NSURL *)urlForCommentsForFight:(Fight *)fight
{
    return [NSURL URLWithString:[URLS appendSessionToken:[NSString stringWithFormat:@"%@/fights/%@/comments",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL,fight.fightID.description]]];
}

+ (NSURL *)urlForTwitterAuth;
{
    return [NSURL URLWithString:@"http://the-boxing-app.herokuapp.com/auth/twitter"];
}

+ (NSURL *)urlForTBATwitterAuth;
{
    return [NSURL URLWithString:@"http://www.theboxingapp.com/auth/twitter"];
}

@end
