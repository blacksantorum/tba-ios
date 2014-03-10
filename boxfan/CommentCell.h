//
//  CommentCell.h
//  boxfan
//
//  Created by Chris Tibbs on 1/25/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@protocol JabCommentDelegate <NSObject>

- (void)jabComment:(Comment *)comment;

@end

@protocol ShowUserDelegate <NSObject>

- (void)showUser:(User *)user;

@end

@protocol CommentDeletedDelegate <NSObject>

- (void)commentDeleted;

@end



@interface CommentCell : UITableViewCell <UIAlertViewDelegate>

@property (strong,nonatomic) Comment *comment;
@property (strong,nonatomic) User *loggedInUser;

@property (weak, nonatomic) IBOutlet UIButton *jabButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterHandleButton;

@property (weak, nonatomic) IBOutlet UITextView *commentContentTextView;

@property (weak, nonatomic) IBOutlet UILabel *commentDateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalJabsLabel;

- (IBAction)jabButtonClicked:(id)sender;
- (IBAction)twitterHandleButtonClicked:(id)sender;

@property (nonatomic,assign)id delegate;

@end
