//
//  SidebarViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 1/13/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "SidebarViewController.h"
#import "BoxFanRevealController.h"
#import <PKRevealController.h>
#import "UpcomingFightNavController.h"
#import "RecentFightNavController.h"
#import "FindUserNavController.h"
#import "MyProfileNavController.h"
#import "SidebarCell.h"
#import "PlacesNavController.h"

@interface SidebarViewController ()

@property (strong,nonatomic) UIStoryboard *storyboard;

@end

@implementation SidebarViewController

-(UIStoryboard *)storyboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

-(User *)loggedInUser
{
    BoxFanRevealController *bfrc= (BoxFanRevealController *)self.revealController;
    return bfrc.loggedInUser;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"Sidebar Cell";
    
    [self.tableView registerClass:[SidebarCell class] forCellReuseIdentifier:CellIdentifier];
    
    SidebarCell *cell = (SidebarCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SidebarCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (SidebarCell *)currentObject;
                break;
            }
        }
    }

    
    if (row == 0) {
        cell.actionTitle.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (row == 4) {
        cell.actionTitle.text = @"Users";
        [cell.actionIcon setImage:[UIImage imageNamed:@"users"]];
    }
    if (row == 1) {
        cell.actionTitle.text = @"Upcoming Fights";
        [cell.actionIcon setImage:[UIImage imageNamed:@"upcoming"]];
    }
    if (row == 2) {
        cell.actionTitle.text = @"Recent Fights";
        [cell.actionIcon setImage:[UIImage imageNamed:@"recent"]];
    }
    if (row == 3) {
        cell.actionTitle.text = self.loggedInUser.handle;
        [cell.actionIcon setImage:[UIImage imageNamed:@"myprofile"]];
    }
    if (row == 5) {
        cell.actionTitle.text = @"Log out";
        [cell.actionIcon setImage:[UIImage imageNamed:@"logout"]];
    }
    if (row == 6) {
        cell.actionTitle.text = @"Places";
        [cell.actionIcon setImage:nil];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == 4) {
        if (![[[self revealController] frontViewController] isKindOfClass:[FindUserNavController class]]) {
            UINavigationController *findUserNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindUserNav"];
            [[self revealController] setFrontViewController:findUserNavController];
            [[self revealController] showViewController:findUserNavController];
        } else {
            [[self revealController] showViewController:[[self revealController] frontViewController]];
        }
    }
    
    if (row == 1) {
        if (![[[self revealController] frontViewController] isKindOfClass:[UpcomingFightNavController class]]) {
            UINavigationController *scheduleNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleNav"];
            [[self revealController] setFrontViewController:scheduleNavController];
            [[self revealController] showViewController:scheduleNavController];
        } else {
            [[self revealController] showViewController:[[self revealController] frontViewController]];
        }
    }
    
    if (row == 2) {
        if (![[[self revealController] frontViewController] isKindOfClass:[RecentFightNavController class]]) {
            UINavigationController *recentNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentNav"];
            [[self revealController] setFrontViewController:recentNavController];
            [[self revealController] showViewController:recentNavController];
        } else {
            [[self revealController] showViewController:[[self revealController] frontViewController]];
        }
    }
    
    if (row == 3) {
        if (![[[self revealController] frontViewController] isKindOfClass:[MyProfileNavController class]]) {
            UINavigationController *myProfileNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileNav"];
            [[self revealController] setFrontViewController:myProfileNavController];
            [[self revealController] showViewController:myProfileNavController];
        } else {
            [[self revealController] showViewController:[[self revealController] frontViewController]];
        }
    }

    if (row == 5) {
        if ([self.delegate respondsToSelector:@selector(logOut)]) {
            [self.delegate logOut];
        }
    }
    
    if (row == 6) {
        if (![[[self revealController] frontViewController] isKindOfClass:[PlacesNavController class]]) {
            UINavigationController *placesNavController = [[UIStoryboard storyboardWithName:@"Places" bundle:nil] instantiateViewControllerWithIdentifier:@"placesNav"];
            [[self revealController] setFrontViewController:placesNavController];
            [[self revealController] showViewController:placesNavController];
        } else {
            [[self revealController] showViewController:[[self revealController] frontViewController]];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 46.0;
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
}

-(void)passUser:(User *)user
{
    self.loggedInUser = user;
}

@end
