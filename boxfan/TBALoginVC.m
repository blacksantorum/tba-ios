//
//  TBALoginVC.m
//  boxfan
//
//  Created by Chris Tibbs on 5/3/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBALoginVC.h"
#import "STTwitterAPI.h"
#import <Parse/Parse.h>

#define TWITTER_CONSUMER_KEY @"TK2igjpRfDN283wGr77Q"
#define TWITTER_CONSUMER_SECRET @"0ju7zB7dl67YsReYmPosJKWVsUbTaLZFiM01CP8Fghs"

@interface TBALoginVC ()

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

- (IBAction)twitterButtonPressed:(id)sender;

@end

@implementation TBALoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.twitterButton.layer.cornerRadius = 6.0;
    /*
    CAGradientLayer *alphaGradientLayer = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                       nil];
    [alphaGradientLayer setColors:colors];
    
    // Start the gradient at the bottom and go almost half way up.
    [alphaGradientLayer setStartPoint:CGPointMake(0.0f, 1.0f)];
    [alphaGradientLayer setEndPoint:CGPointMake(0.0f, 0.6f)];
    
    [alphaGradientLayer setFrame:[self.twitterButton bounds]];
    [[self.twitterButton layer] setMask:alphaGradientLayer];
     */
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
    
    NSLog(@"%@",result);
    [[User getCurrentUser] updateWithTwitterResponse:result];
    
}

@end
