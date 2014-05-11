//
//  TBALoginVC.m
//  boxfan
//
//  Created by Chris Tibbs on 5/3/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBALoginVC.h"
#import "STTwitterAPI.h"
#import "User.h"
#import <Parse/Parse.h>

#define TWITTER_CONSUMER_KEY @"TK2igjpRfDN283wGr77Q"
#define TWITTER_CONSUMER_SECRET @"0ju7zB7dl67YsReYmPosJKWVsUbTaLZFiM01CP8Fghs"

@interface TBALoginVC () <TBAUserLoginDelegate>

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

- (IBAction)twitterButtonPressed:(id)sender;

@end

@implementation TBALoginVC

- (void)currentUserLoggedin
{
    [self performSegueWithIdentifier:@"enterApp" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.twitterButton.layer.cornerRadius = 6.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [User getCurrentUser].delegate = self;
    if ([self encodedUserFromDefaults]) {
        NSData *encodedUser = [self encodedUserFromDefaults];
        [[User getCurrentUser] updateCurrentUserWithEncodedUser:encodedUser];
        [User getCurrentUser].isLoggedIn = YES;
    }

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)twitterButtonPressed:(id)sender {
    [self reverseAuth];
}
        
- (NSData *)encodedUserFromDefaults
{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults objectForKey:@"User"];
}
        
#pragma mark - Twitter sign in, backend sign in

- (void)reverseAuth
{
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil
                                                              consumerKey:TWITTER_CONSUMER_KEY
                                                           consumerSecret:TWITTER_CONSUMER_SECRET];
    
    [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                successBlock:^(NSString *oAuthToken,
                                                                               NSString *oAuthTokenSecret,
                                                                               NSString *userID,
                                                                               NSString *screenName) {
                                                                    
                                                                    [self signInViaParseWithTwitterID:userID
                                                                                           screenName:username
                                                                                           oAuthToken:oAuthToken
                                                                                     oAuthTokenSecret:oAuthTokenSecret];
                                                                    
                                                                } errorBlock:^(NSError *error) {
                                                                    NSLog(@"%@",error.localizedDescription);
                                                                }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}

- (void)signInViaParseWithTwitterID:(NSString *)twitterID
                         screenName:(NSString *)screenName
                         oAuthToken:(NSString *)oAuthToken
                   oAuthTokenSecret:(NSString *)oAuthTokenSecret
{
    [PFTwitterUtils logInWithTwitterId:twitterID screenName:screenName authToken:oAuthToken authTokenSecret:oAuthTokenSecret block:^(PFUser *user, NSError *error) {
        if (!error) {
            [self makeSignedRequestToTwitterAndLoginWithResult];
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];

}

- (void)makeSignedRequestToTwitterAndLoginWithResult
{
    NSString *twitterScreenName = [PFTwitterUtils twitter].screenName;
    NSURL *verify = [NSURL URLWithString:[URLS urlStringForUsersTwitterWithScreenname:twitterScreenName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    [[User getCurrentUser] updateWithTwitterResponse:result];
    // NSLog(@"%@", [User getCurrentUser]);
    [[User getCurrentUser] signInWithBackend];
}

@end
