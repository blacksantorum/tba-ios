//
//  RecentFightDisplayViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 1/22/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "RecentFightDisplayViewController.h"
#import "FightInfoCell.h"
#import "PickInfoCell.h"
#import "DecisionInfoCell.h"
#import "ScheduleFormattedDate.h"
#import "boxfanAppDelegate.h"
#import <Social/Social.h>

@interface RecentFightDisplayViewController ()

@property NSDictionary *boxersToPickPercentages;
@property NSDictionary *boxersToDecisionPercentages;

@end

@implementation RecentFightDisplayViewController

- (void)changeFOY
{
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager POST:[URLS urlStringForUpdatingFOYtoFight:self.fight] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        [self showFOYTweetSheet];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                        message:@"Your update could not be completed. Please check your data connection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
    self.loggedInUser.foy = self.fight;
    [self refresh];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.fight.stoppage) {
        return 3;
    } else {
        return 4;
    }
}

- (void)showFOYChangeAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fight of the Year" message:[NSString stringWithFormat:@"Change your Fight of the Year to %@?",self.fight.titleForScheduleView] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self changeFOY];
    }
}

#pragma mark - Action Sheet stuff

-(void)changeDecision
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Who do you think won %@",self.fight.titleForScheduleView]
                                                             delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:self.fight.boxerA.boxerFullName,self.fight.boxerB.boxerFullName,nil];
    
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (![buttonTitle isEqualToString:@"Cancel"]) {
        NSString *postURLString = [URLS urlStringForPostingDecisionForFight:self.fight];
        
        Boxer *decidedBoxer = buttonIndex == 0 ? self.fight.boxerA : self.fight.boxerB;
        
        Decision *decision = [[Decision alloc] init];
        decision.fight = self.fight;
        decision.winner = decidedBoxer;
        
        if (decidedBoxer.boxerID == self.fight.boxerA.boxerID) {
            decision.loser = self.fight.boxerB;
        } else {
            decision.loser = self.fight.boxerA;
        }
        
        [self postUserActivityDictionary:[self postDictionaryForDeciding:decidedBoxer] toURLString:postURLString];
        
        [self showTweetSheet:decision];
    }
}

- (void)showFOYTweetSheet
{
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    /*
    [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ is my new Fight of the Year! #TBA",self.fight.titleForScheduleView]];
    
    [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://theboxingapp.com/fights/%@",self.fight.fightID.description]]];
    */
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

- (void)showTweetSheet:(Decision *)decision
{
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    [tweetSheet setInitialText:[NSString stringWithFormat:@"I thought %@ beat %@ #TBA",decision.winner.boxerFullName,decision.loser.boxerFullName]];
    
    
    [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://theboxingapp.com/fights/%ld",(long)self.fight.fightID]]];
    
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

-(NSDictionary *)postDictionaryForDeciding:(Boxer *)boxer
{
    return @{@"decision":@{@"winner_id": [NSNumber numberWithInteger:boxer.boxerID]}};
}

-(void)postUserActivityDictionary:(NSDictionary *)dictionary toURLString:(NSString *)url
{
    DecisionInfoCell *cell = (DecisionInfoCell *)[self.fightInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    cell.makeDecisionButton.titleLabel.text = @"Updating...";
    cell.makeDecisionButton.enabled = NO;
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager POST:url parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        [self refresh];
        cell.makeDecisionButton.enabled = YES;
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                        message:@"Your update could not be completed. Please check your data connection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        cell.makeDecisionButton.titleLabel.text = @"Update decision";
        cell.makeDecisionButton.enabled = YES;

        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
}



@end
