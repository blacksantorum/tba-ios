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
#import "boxfanAppDelegate.h"
#import "Pick.h"
#import <math.h>

@interface CommentsDisplayVC () {
    NSMutableDictionary *textViews;
    BOOL frameSet;
}

@property (strong,nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong,nonatomic) UIActivityIndicatorView *spinner;
@property (strong,nonatomic) UITextField *commentField;

@property (nonatomic) CGRect originalToolbarFrame;

@end

@implementation CommentsDisplayVC

- (void)setOriginalToolbarFrame:(CGRect)originalToolbarFrame
{
    if (!frameSet) {
        frameSet = YES;
    }
    _originalToolbarFrame = originalToolbarFrame;
}

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
    
    self.commentField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 32)];
    self.commentField.placeholder = @"Enter comment:";
    
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addComment)];
    
    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:self.commentField];
    
    NSArray *items = [NSArray arrayWithObjects:textFieldItem,flexibleItem,addButton, nil];
    self.toolbarItems = items;
    
    self.commentField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self addActivityViewIndicator];
    // [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"connectionRestored" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
    if (!frameSet) {
        self.originalToolbarFrame = self.navigationController.toolbar.frame;
    }
    [self refresh];
}

- (void)addComment
{
    NSDictionary *dictionary = @{@"comment":@{@"body" : self.commentField.text}};
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager POST:[URLS urlStringForPostingCommentForFight:self.fight] parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self refresh];
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        self.commentField.text = @"";
        [self.commentField endEditing:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                        message:@"Your update could not be completed. Please check your data connection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
    
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
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.spinner startAnimating];
 
    NSURLRequest *request = [NSURLRequest requestWithURL:[URLS urlForCommentsForFight:self.fight]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
        
        } else {
            NSError *error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                                message:@"Please check your data connection"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
            
                NSArray *array = (NSArray *)object;
                NSLog(@"%@",array);
                NSMutableArray *comments = [[NSMutableArray alloc] init];
                for (NSDictionary *dictionary in array) {
                    NSDictionary *commentDictionary = [dictionary objectForKey:@"comment"];
                    Comment *c = [[Comment alloc] initWithDictionary:commentDictionary];
                    
                    NSDictionary *pickDictionary = [commentDictionary objectForKey:@"pick"];
                    if (![JSONDataNullCheck isNull:pickDictionary]) {
                        Pick *pick = [[Pick alloc] init];
                        pick.fight = self.fight;
                        NSString *ko = [pickDictionary objectForKey:@"ko"];
                        if ([ko.description isEqualToString:@"1"]) {
                            pick.byStoppage = YES;
                        } else {
                            pick.byStoppage = NO;
                        }
                        pick.user = c.author;
                        
                        Boxer *pickedBoxer;
                        NSString *pickedBoxerID = [pickDictionary objectForKey:@"winner_id"];
                        for (Boxer *b in self.fight.boxers) {
                            if ([pickedBoxerID.description isEqualToString:b.boxerID.description]) {
                                pickedBoxer = b;
                            }
                        }
                        pick.winner = pickedBoxer;
                        c.pick = pick;
                    }
                    
                    [comments addObject:c];
                }
                
                self.comments = comments;
                
                [self.tableView reloadData];
            }
        }
        [self.spinner stopAnimating];
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (NSArray *)sortCommentsArray:(NSArray *)array
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    // must override
    return mutableArray;
}

#pragma mark - Table view data source

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // amount of comments
    return [self.comments count];
}

- (NSString *)commentCellDetailStringForComment:(Comment *)comment
{
    Boxer *pickedBoxer = comment.pick.winner;
    return [NSString stringWithFormat:@" (%@ by %@)",pickedBoxer.lastName, comment.pick.byStoppage ? @"KO": @"dec"];
}

- (NSString *)handleTitleForComment:(Comment *)comment
{
    NSString *title = comment.author.handle;
    if (comment.pick) {
        title = [title stringByAppendingString:[self commentCellDetailStringForComment:comment]];
    }
    return title;
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
    
    cell.comment = comment;
    
    [cell.jabButton setImage:[self jabButtonImageForComment:comment] forState:UIControlStateNormal];
     cell.twitterHandleButton.tintColor = [UIColor blackColor];
    [cell.twitterHandleButton setTitle:[self handleTitleForComment:comment] forState:UIControlStateNormal];
    [cell.twitterHandleButton setTitle:[self handleTitleForComment:comment] forState:UIControlStateHighlighted];
    
    [cell.commentContentTextView setText:nil];
    cell.commentContentTextView.text = comment.content;
    
    cell.commentContentTextView.scrollEnabled = NO;
    
    
    
    
    TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
    
    // formatted time interval from comment date to now
    cell.commentDateTimeLabel.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:comment.date];
    cell.totalJabsLabel.text = [NSString stringWithFormat:@"%d",(int)comment.jabs];
    
    [textViews setObject:cell.commentContentTextView forKey:indexPath];
    cell.commentContentTextView.delegate = self;
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    NSString *url;
    if (comment.isJabbedByLoggedInUser) {
        url = [URLS urlStringForUnjabbingComment:comment];
    } else {
        url = [URLS urlStringForJabbingComment:comment];
    }
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                        message:@"Please check your data connection and try that jab again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
}

-(void)showUser:(User *)user
{
    UserProfileController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    controller.displayedUser = user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath {
    UITextView *calculationView = [textViews objectForKey: indexPath];
    // CGFloat textViewWidth = calculationView.frame.size.width;
    // if (!calculationView.attributedText) {
        // This will be needed on load, when the text view is not inited yet
        
        calculationView = [[UITextView alloc] init];
        
        Comment *comment = self.comments[indexPath.row];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:comment.content attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]}];
        calculationView.attributedText = string;
        CGFloat textViewWidth = 238.0;
    // }
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat calculatedHeight = [self textViewHeightForRowAtIndexPath:indexPath] + 50;
    if (calculatedHeight < 90) {
        return 90;
    } else {
        return calculatedHeight;
    }
}

- (NSString *)getTextForIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = self.comments[indexPath.row];
    
    return comment.content;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationController.toolbarHidden = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect toolBarFrame = self.navigationController.toolbar.frame;
    __weak CommentsDisplayVC *weakSelf = self;
    [UIView animateWithDuration:0.25
                     animations:^{
                         [weakSelf.navigationController.toolbar setFrame:CGRectMake(0, keyboardFrame.origin.y - toolBarFrame.size.height , toolBarFrame.size.width, toolBarFrame.size.height)];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.navigationController.toolbar setFrame:self.originalToolbarFrame];
                     }
                     completion:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionRestored" object:nil];
}

@end
