//
//  BoxingAppDVC.m
//  boxfan
//
//  Created by Chris Tibbs on 1/8/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "BoxingAppDVC.h"
#import "URLS.h"
#import <Parse/Parse.h>
#import <PKRevealController/PKRevealController.h>
#import "BoxingScheduleVC.h"
#import "boxfanAppDelegate.h"

@interface BoxingAppDVC ()

@property (strong, nonatomic)  UIActivityIndicatorView *spinner;

@end

@implementation BoxingAppDVC

// carry Logged in user from RootViewController

- (User *)loggedInUser
{
    BoxFanRevealController *bfrc= (BoxFanRevealController *)self.revealController;
    return bfrc.loggedInUser;
}

// open side bar

- (IBAction)userClickedShowSettings:(id)sender
{
    [self showSettingsMenu];
}

- (void)showSettingsMenu
{
    [[self revealController] showViewController:[[self revealController] leftViewController]];
}

// make a call to the supplied URL, store the response in an Array of JSON objects

- (void)addActivityViewIndicator
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.spinner];
    self.spinner.center = self.view.center;
}

- (void)refresh
{
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.spinner startAnimating];

    NSURLRequest *request = [NSURLRequest requestWithURL:self.urlForRequest];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                            message:@"Please check your data connection"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        } else {
            NSError *error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
        
            } else {
                self.JSONarray = (NSArray *)object;
                [self configureDataSource];
                [self.tableView reloadData];
            }
        }
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        [self.spinner stopAnimating];
    }];
}

- (void)configureDataSource
{
    //override
}

- (void)doLogInStuff
{
    // override if necessary
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addActivityViewIndicator];
    [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"connectionRestored" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionRestored" object:nil];
}
@end
