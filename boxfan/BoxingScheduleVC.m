//
//  BoxingScheduleVC.m
//  boxfan
//
//  Created by Chris Tibbs on 1/8/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "BoxingScheduleVC.h"
#import "ScheduleFormattedDate.h"
#import "Fight.h"
#import "Boxer.h"
#import "UpcomingFightVC.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface BoxingScheduleVC ()

@property (nonatomic,strong) NSArray *fightDates;
@property (nonatomic,strong) NSArray *fights;

-(NSArray *)fightsForDate:(NSDate *)date;
-(NSDictionary *)userDictionaryFromTwitter;

@end

@implementation BoxingScheduleVC

#pragma mark - Log In Stuff

-(void)signInWithRails:(User *)user
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = user.userDictionaryForSignIn;
    [manager POST:[URLS urlStringForRailsSignIn] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *userDictionary = responseObject;
        NSLog(@"%@", userDictionary);
        NSLog(@"%@",[userDictionary valueForKeyPath:@"user.id"]);
        user.userID = [userDictionary valueForKeyPath:@"user.id"];
        NSLog(@"%@",[userDictionary valueForKeyPath:@"user.session_token"]);
        NSString *token = [userDictionary valueForKeyPath:@"user.session_token"];
        [self saveUserInDefaults:user withSessionToken:token];
        self.user = user;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [logInController dismissViewControllerAnimated:YES completion:nil];
    
    User *boxingAppUser = [[User alloc] initWithDictionary:[self userDictionaryFromTwitter]];
    
    [self signInWithRails:boxingAppUser];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

-(void)doLogInStuff
{
    
    
   if (![PFUser currentUser]) {
        // If not logged in, we will show a PFLogInViewController
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        
        // Customize the Log In View Controller
        logInViewController.delegate = self;
        // logInViewController.facebookPermissions = @[@"friends_about_me"];
        logInViewController.fields = PFLogInFieldsTwitter | PFLogInFieldsDismissButton; // Show Twitter login, Facebook login, and a Dismiss button.
        
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

-(NSArray *)fightDates
{
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    for (Fight *f in self.fights) {
        [dateArray addObject:f.date];
    }
    NSSet *dateSet = [NSSet setWithArray:dateArray];
    NSArray *dates = [dateSet allObjects];
    _fightDates = [dates sortedArrayUsingSelector:@selector(compare:)];
    
    return _fightDates;
}

-(NSArray *)fightsForDate:(NSDate *)date
{
    NSMutableArray *fightsForDate = [[NSMutableArray alloc] init];
    
    for (Fight *f in self.fights) {
        if ([f.date isEqualToDate:date]) {
            [fightsForDate addObject:f];
        }
    }
    
    return fightsForDate;
}


-(NSURL *)urlForRequest
{
    return [URLS urlForUpcomingFights];
}

-(void)configureDataSource
{
    NSMutableArray *fightArray = [[NSMutableArray alloc] init];
    for (NSDictionary *fightDictionary in self.JSONarray) {
        Fight *f = [[Fight alloc] initWithDictionary:fightDictionary[@"fight"]];
        NSMutableArray *boxers = [[NSMutableArray alloc] init];
        for (NSDictionary *boxerDictionary in [fightDictionary valueForKeyPath:@"fight.boxers"]){
            
            Boxer *b = [[Boxer alloc] initWithDictionary:boxerDictionary[@"boxer"]];
            [boxers addObject:b];
        }
        f.boxers = boxers;
        [fightArray addObject:f];
    }
    self.fights = fightArray;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"upcomingFightDetail"]) {
        UpcomingFightVC *controller = (UpcomingFightVC *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSDate *date = [self.fightDates objectAtIndex:indexPath.section];
        NSArray *fightsForDate = [self fightsForDate:date];
        
        Fight *fight = fightsForDate[indexPath.row];
        
        controller.user = self.user;
        controller.fight = fight;
        controller.title = fight.titleForScheduleView;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fightDates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *date = [self.fightDates objectAtIndex:section];
    NSArray *fightsForDate = [self fightsForDate:date];
    return fightsForDate.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *date = [self.fightDates objectAtIndex:section];
    return [ScheduleFormattedDate sectionHeaderFormattedStringFromDate:date];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Upcoming Fight Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDate *date = [self.fightDates objectAtIndex:indexPath.section];
    NSArray *fightArrayAtDate = [self fightsForDate:date];
    Fight *fight = fightArrayAtDate[indexPath.row];
    cell.textLabel.text = fight.titleForScheduleView;
    
    return cell;
}

@end
