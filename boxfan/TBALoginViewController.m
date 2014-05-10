//
//  TBALoginViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 1/31/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBALoginViewController.h"
#import "boxfanAppDelegate.h"

@interface TBALoginViewController ()

@end

@implementation TBALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.logInView setBackgroundColor:[UIColor grayColor]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    //[self.logInView.twitterButton setTitle:@" Sign in with Twitter" forState:UIControlStateNormal];
    //[self.logInView.twitterButton setTitle:@" Sign in with Twitter" forState:UIControlStateHighlighted];
    UIButton *logIn = [UIButton buttonWithType:UIButtonTypeSystem];
    logIn.frame = CGRectMake(25, 300, 50, 10);
    [logIn setTitle:@"Log in" forState:UIControlStateNormal];
    [logIn addTarget:self action:@selector(doLogIn) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView.twitterButton removeFromSuperview];
    [self.view addSubview:logIn];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    [self.logInView.logo setFrame:CGRectMake(66.5f, 175.0f, 187.0f, 58.5f)];
    // [self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
}

- (void)doLogIn
{
    boxfanAppDelegate *delegate = (boxfanAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate reverseAuthAndSignInViaParse];
}

@end
