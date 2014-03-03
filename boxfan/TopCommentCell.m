//
//  TopCommentCell.m
//  boxfan
//
//  Created by Chris Tibbs on 2/4/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TopCommentCell.h"

@implementation TopCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (self) {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"TopCommentCell" owner:self options:nil];
            self = [nibArray objectAtIndex:0];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    self.commentContentTextView.selectable = YES;
    self.commentContentTextView.scrollEnabled = NO;
}

@end
