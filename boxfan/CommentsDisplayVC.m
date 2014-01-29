//
//  CommentsDisplayVC.m
//  boxfan
//
//  Created by Chris Tibbs on 1/24/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "CommentsDisplayVC.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "Comment.h"
#import "TTTTimeIntervalFormatter.h"
#import "BoxFanRevealController.h"
#import "UserProfileController.h"

@interface CommentsDisplayVC ()

@property (strong,nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong,nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation CommentsDisplayVC

-(User *)loggedInUser
{
    BoxFanRevealController *bfrc= (BoxFanRevealController *)self.revealController;
    return bfrc.loggedInUser;
}

- (AFHTTPRequestOperationManager *)manager
{
    if (!_manager) {
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[URLS baseURL]];
    }
    return _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
    
    UITextField *textField = [[UITextField alloc] init];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:textField];
    
    NSArray *items = [NSArray arrayWithObjects:addButton, flexibleItem, textFieldItem, nil];
    self.toolbarItems = items;
    
    [self refresh];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showUser" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserProfileController *controller = (UserProfileController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Comment *comment = self.comments[indexPath.row];
        
        controller.displayedUser = comment.author;
        controller.title = comment.author.handle;
    }
}

- (void)addActivityViewIndicator
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.spinner];
    self.spinner.center = self.view.center;
}

- (void)refresh
{
    [self addActivityViewIndicator];
    [self.spinner startAnimating];
    NSLog(@"%@", [URLS urlForCommentsForFight:self.fight]);
    NSURLRequest *request = [NSURLRequest requestWithURL:[URLS urlForCommentsForFight:self.fight]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Connection error: %@", connectionError);
        } else {
            NSError *error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                NSLog(@"JSON parsing error: %@", error);
            } else {
                NSLog(@"%@",object);
                NSArray *array = (NSArray *)object;
                
                NSMutableArray *comments = [[NSMutableArray alloc] init];
                for (NSDictionary *dictionary in array) {
                    Comment *c = [[Comment alloc] initWithDictionary:[dictionary objectForKey:@"comment"]];
                    [comments addObject:c];
                }
                
                self.comments = comments;
                
                [self.tableView reloadData];
                [self.spinner stopAnimating];
            }
        }
    }];
}

- (NSArray *)sortCommentsArray:(NSArray *)array
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    // must override
    return mutableArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // amount of comments
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Comment Cell";
    
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:CellIdentifier];
    
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (CommentCell *)currentObject;
                break;
            }
        }
    }
    
    Comment *comment = self.comments[indexPath.row];
    
    [cell.jabButton setImage:[self jabButtonImageForComment:comment] forState:UIControlStateNormal];
    cell.twitterHandleLabel.text = comment.author.handle;
    cell.commentContentLabel.text = comment.content;
    
    TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
    
    // formatted time interval from comment date to now
    cell.commentDateTimeLabel.text = [formatter stringForTimeIntervalFromDate:comment.date toDate:[NSDate date]];
    cell.totalJabsLabel.text = [NSString stringWithFormat:@"%d",(int)comment.jabs];
    
    cell.delegate = self;
        
    return cell;
}

- (UIImage *)jabButtonImageForComment:(Comment *)comment
{
    if (comment.isJabbedByLoggedInUser) {
        return [UIImage imageNamed:@"jabbed"];
    } else {
        return [UIImage imageNamed:@"notjabbed"];
    }
}

-(void)jabComment:(Comment *)comment
{
    // send post
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 87.0;
}

@end
