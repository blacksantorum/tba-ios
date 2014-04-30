//
//  CommentCell.m
//  boxfan
//
//  Created by Chris Tibbs on 1/25/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "CommentCell.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "boxfanAppDelegate.h"

@interface CommentCell ()

@property (strong,nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation CommentCell

- (AFHTTPRequestOperationManager *)manager
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/",[URLS prod] ? PROD_BASE_URL : TEST_BASE_URL]];
    
    if (!_manager) {
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return _manager;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
    }
    return self;
}


- (IBAction)jabButtonClicked:(id)sender {
    NSInteger newJabs = [self.totalJabsLabel.text integerValue];
    
    if (self.comment.isJabbedByLoggedInUser) {
        newJabs--;
    } else {
        newJabs++;
    }
    self.totalJabsLabel.text = [NSString stringWithFormat:@"%ld",(long)newJabs];
    
    if (self.comment.isJabbedByLoggedInUser) {
        [self.jabButton setImage:[UIImage imageNamed:@"notjabbed"] forState:UIControlStateNormal];
    } else {
        [self.jabButton setImage:[UIImage imageNamed:@"jabbed"] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(jabComment:)]) {
        [self.delegate jabComment:self.comment];
    }
    self.comment.isJabbedByLoggedInUser = !self.comment.isJabbedByLoggedInUser;
}

- (IBAction)twitterHandleButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(showUser:)]) {
        [self.delegate showUser:self.comment.author];
    }
}

- (void)deleteComment:(Comment *)comment
{
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager DELETE:[URLS urlStringForDeletingComment:comment] parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if ([self.delegate respondsToSelector:@selector(commentDeleted)]) {
                         [self.delegate commentDeleted];
                     }
                     [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                                     message:@"Your update could not be completed. Please check your data connection."
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];

    }];
}

- (IBAction)showDeleteAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete comment"
                                                    message:@"Are you sure you would like to delete this comment?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    [alert setTag:1];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        [self deleteComment:self.comment];
    }
}

- (void)layoutSubviews
{
    CGFloat fixedWidth = self.commentContentTextView.frame.size.width;
    CGSize newSize = [self.commentContentTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.commentContentTextView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    self.commentContentTextView.frame = newFrame;
    
    CGRect newFrameForTime = self.commentDateTimeLabel.frame;
    CGFloat newY = newFrame.origin.y + newFrame.size.height;
    self.commentDateTimeLabel.frame = CGRectMake(newFrameForTime.origin.x, newY, newFrameForTime.size.width, newFrameForTime.size.height);
    
    /*
    if ([self.comment.author isEqualToUser:self.loggedInUser]) {
        deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect timeLabelFrame = self.commentDateTimeLabel.frame;
        deleteButton.frame = CGRectMake(259.0, timeLabelFrame.origin.y, 46.0, 30.0);
        [deleteButton addTarget:self action:@selector(showDeleteAlert:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitle:@"Delete" forState:UIControlStateHighlighted];
        
        deleteButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self addSubview:deleteButton];
    }
    */
    
}

@end
