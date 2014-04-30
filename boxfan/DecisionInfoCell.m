//
//  DecisionInfoCell.m
//  boxfan
//
//  Created by Chris Tibbs on 1/22/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "DecisionInfoCell.h"
#import <MSGradientArcLayer.h>

@implementation DecisionInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"DecisionInfoCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)makeDecisionButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(changeDecision)]) {
        [self.delegate changeDecision];
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
        [self.gauge setValue:50.0];
    } else {
        [self.gauge setValue:self.boxerBPercentage animated:YES];
    }
    // self.gauge.fillGradient = [MSGradientArcLayer defaultGradient];
    self.gauge.fillArcFillColor = [[UIColor blueColor] colorWithAlphaComponent:0.15];
    [self.contentView addSubview:self.gauge];
    
}
@end
