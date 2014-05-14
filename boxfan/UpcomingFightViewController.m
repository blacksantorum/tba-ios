//
//  UpcomingFightViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 1/21/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "UpcomingFightViewController.h"
#import "FightInfoCell.h"
#import "ScheduleFormattedDate.h"
#import "boxfanAppDelegate.h"
#import <Social/Social.h>

@interface UpcomingFightViewController ()

@property (strong,nonatomic) NSDictionary *boxersToPickPercentages;

@end

@implementation UpcomingFightViewController


#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark - Action Sheet stuff

-(void)changePick
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Make your pick for %@",self.fight.titleForScheduleView]
                                                             delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[NSString stringWithFormat:@"%@ by dec",self.fight.boxerA.lastName],
                                  [NSString stringWithFormat:@"%@ by KO",self.fight.boxerA.lastName],
                                  [NSString stringWithFormat:@"%@ by dec",self.fight.boxerB.lastName],
                                  [NSString stringWithFormat:@"%@ by KO",self.fight.boxerB.lastName],nil];
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (![buttonTitle isEqualToString:@"Cancel"]) {
        NSString *postURLString = [URLS urlStringForPostingPickForFight:self.fight];
        
        Boxer *pickedBoxer = buttonIndex == 0 || buttonIndex == 1 ? self.fight.boxerA : self.fight.boxerB;
        
        BOOL ko = (buttonIndex == 1 || buttonIndex == 3);
        
        Pick *pick = [[Pick alloc] init];
        pick.fight = self.fight;
        pick.winner = pickedBoxer;
        
        if (pickedBoxer.boxerID == self.fight.boxerA.boxerID) {
            pick.loser = self.fight.boxerB;
        } else {
            pick.loser = self.fight.boxerA;
        }
        
        pick.byStoppage = ko;
        
        [self postUserActivityDictionary:[self postDictionaryForPicking:pickedBoxer byKO:ko] toURLString:postURLString];
        
        [self showTweetSheet:pick];
    }
}

- (void)showTweetSheet:(Pick *)pick
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
    
    [tweetSheet setInitialText:[NSString stringWithFormat:@"I'm picking %@ over %@ %@ #TBA",pick.winner.boxerFullName,pick.loser.boxerFullName, (pick.byStoppage) ? @"by KO" : @"by decision"]];
    
    [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://theboxingapp.com/fights/%ld",(long)self.fight.fightID]]];
    
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

-(NSDictionary *)postDictionaryForPicking:(Boxer *)boxer byKO:(BOOL)ko
{
    return @{@"pick":@{@"winner_id": [NSNumber numberWithInteger:boxer.boxerID], @"ko":[self stringForBool:ko]}};
}

-(NSString *)stringForBool:(BOOL)boolean
{
    if (boolean) {
        return @"true";
    } else {
        return @"false";
    }
}

-(void)postUserActivityDictionary:(NSDictionary *)dictionary toURLString:(NSString *)url
{
    PickInfoCell *cell = (PickInfoCell *)[self.fightInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    cell.makePickButton.titleLabel.text = @"Updating...";
    cell.makePickButton.enabled = NO;
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager POST:url parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self refresh];
        cell.makePickButton.enabled = YES;
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                        message:@"Your update could not be completed. Please check your data connection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        cell.makePickButton.titleLabel.text = @"Update pick";
        cell.makePickButton.enabled = YES;

        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
}


@end
