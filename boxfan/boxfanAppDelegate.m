//
//  boxfanAppDelegate.m
//  boxfan
//
//  Created by Chris Tibbs on 12/15/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import "boxfanAppDelegate.h"
#import <Parse/Parse.h>
#import "TBALoginViewController.h"
#import "Auth.h"
#import <PKRevealController/PKRevealController.h>
#import "BoxingScheduleVC.h"
#import "BoxFanRevealController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TBARailsClient.h"

#define NavigationBarColor [UIColor colorWithRed:.170 green:.001 blue:.02 alpha:.8]

@interface boxfanAppDelegate() <PKRevealing>

@property (nonatomic,strong,readwrite) BoxFanRevealController *revealController;

@end

@implementation boxfanAppDelegate

- (BOOL)prod
{
    return YES;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
   //  NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

-(void)doParseInitialization
{
    [Parse setApplicationId:@"1B14Hx2kPtRNvaupWjUNlmwPrJOsgZQ6qJv5tUDF"
                  clientKey:@"ygFW72dJh6tk3jbTxcEQoFbbROXRSIxaqldcv9Ik"];
    [PFTwitterUtils initializeWithConsumerKey:@"TK2igjpRfDN283wGr77Q"
                               consumerSecret:@"0ju7zB7dl67YsReYmPosJKWVsUbTaLZFiM01CP8Fghs"];
    
    [UIColor colorWithRed:.139 green:0 blue:0 alpha:1];
}

-(void)signInWithRails:(User *)user
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [self setNetworkActivityIndicatorVisible:YES];
    NSDictionary *parameters = user.userDictionaryForSignIn;
    [manager POST:[URLS urlStringForRailsSignIn] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *userDictionary = responseObject;
        user.userID = [userDictionary valueForKeyPath:@"user.id"];
        NSString *token = [userDictionary valueForKeyPath:@"user.session_token"];
        [self saveUserInDefaults:user withSessionToken:token];
        [self setUpRevealController];
        [self setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkActivityIndicatorVisible:NO];
    }];
}

-(NSDictionary *)userDictionaryFromTwitter
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
    return result;
}

-(void)saveUserInDefaults:(User *)user
         withSessionToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
    [defaults setObject:encodedUser forKey:@"User"];
    [defaults setObject:token forKey:@"Token"];
    [defaults synchronize];
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(TBALoginViewController *)logInController didLogInUser:(PFUser *)user {
    User *boxingAppUser = [[User alloc] initWithDictionary:[self userDictionaryFromTwitter]];
    
    [self signInWithRails:boxingAppUser];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(TBALoginViewController *)logInController didFailToLogInWithError:(NSError *)error {
}

-(void)setUpRevealController
{
    // front
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *frontNavController = [storyboard instantiateViewControllerWithIdentifier:@"ScheduleNav"];
    // UINavigationController *frontNavController = [[UINavigationController alloc] initWithRootViewController:scheduleView];
    
    // left
    SidebarViewController *sideBarController = [[SidebarViewController alloc] initWithNibName:@"SidebarViewController" bundle:nil];
    sideBarController.delegate = self;
    
    self.revealController = [BoxFanRevealController revealControllerWithFrontViewController:frontNavController leftViewController:sideBarController];
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:[self encodedUserFromDefaults]];
    self.revealController.loggedInUser = user;
    
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    
    self.window.rootViewController = self.revealController;
    
    [self.window makeKeyAndVisible];
}

-(NSData *)encodedUserFromDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"User"];
}

- (void)showLogInView
{
    TBALoginViewController *logInViewController = [[TBALoginViewController alloc] init];
    logInViewController.delegate = self;
    logInViewController.fields = PFLogInFieldsTwitter;
    
    self.window.rootViewController = logInViewController;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self doParseInitialization];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UINavigationBar appearance] setBarTintColor:NavigationBarColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue" size:18.0], NSFontAttributeName, nil]];
    
    
    if (![self encodedUserFromDefaults]) {
        [self showLogInView];
    } else {
        [self setUpRevealController];
    }
    
    // [[TBARailsClient sharedClient] fetchUpcomingFights];
    
    return YES;
}

- (void)logOut
{
    [PFUser logOut];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"User"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Token"];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookiesForURL:[URLS urlForTwitterAuth]]) {
        [storage deleteCookie:cookie];
    }
    
    for (cookie in [storage cookiesForURL:[URLS urlForTBATwitterAuth]]) {
        [storage deleteCookie:cookie];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.revealController.loggedInUser = nil;
    
    
    
    [self showLogInView];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
