//
//  boxfanAppDelegate.h
//  boxfan
//
//  Created by Chris Tibbs on 12/15/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SidebarViewController.h"

@interface boxfanAppDelegate : UIResponder <UIApplicationDelegate,PFLogInViewControllerDelegate,LogOutDelegate>

@property (nonatomic) BOOL prod;

@property (strong, nonatomic) UIWindow *window;

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

- (void)reverseAuthAndSignInViaParse;

@end
