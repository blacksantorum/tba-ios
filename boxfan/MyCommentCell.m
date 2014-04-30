//
//  MyCommentCell.m
//  boxfan
//
//  Created by Chris Tibbs on 3/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "MyCommentCell.h"

@implementation MyCommentCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect timeLabelFrame = self.commentDateTimeLabel.frame;
    self.deleteCommentButton.frame = CGRectMake(259.0, timeLabelFrame.origin.y, 46.0, 30.0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MyCommentCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
    }
    return self;
}

@end
