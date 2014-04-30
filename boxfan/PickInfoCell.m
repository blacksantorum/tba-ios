//
//  PickInfoCell.m
//  boxfan
//
//  Created by Chris Tibbs on 1/21/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "PickInfoCell.h"
#import <MSGradientArcLayer.h>

@interface PickInfoCell () {
    
}
@end

@implementation PickInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (self) {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"PickInfoCell" owner:self options:nil];
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

- (IBAction)makePickButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(changePick)]) {
        [self.delegate changePick];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect gaugeFrame				= CGRectMake(35.0,
                                                 -100.0,
                                                 250.0,
                                                 250.0);
    self.gauge = [[MSSimpleGauge alloc] initWithFrame:gaugeFrame];
    
    if (self.boxerAPercentage == 0.0 && self.boxerBPercentage == 0.0) {
        [self.gauge setValue:50];
    } else {
        [self.gauge setValue:self.boxerBPercentage animated:YES];
    }
    
    self.gauge.fillArcFillColor = [[UIColor redColor] colorWithAlphaComponent:0.15];
    // self.gauge.fillGradient = [MSGradientArcLayer defaultGradient];
    [self.contentView addSubview:self.gauge];
     
}

@end
