//
//  CommentsDisplayVC.h
//  boxfan
//
//  Created by Chris Tibbs on 1/24/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentCell.h"

@interface CommentsDisplayVC : UITableViewController <JabCommentDelegate,ShowUserDelegate,CommentDeletedDelegate,UITextViewDelegate>

@property (nonatomic,strong) Fight *fight;
@property (nonatomic,strong) User *loggedInUser;
@property (nonatomic,strong) NSArray *comments;

- (void)refresh;
- (NSArray *)sortCommentsArray:(NSArray *)array;

@end
