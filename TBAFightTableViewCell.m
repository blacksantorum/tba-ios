//
//  TBAFightTableViewCell.m
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBAFightTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Fight.h"
#import "Boxer.h"

@interface TBAFightTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *fighterAPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *fighterANameLabel;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (weak, nonatomic) IBOutlet UIImageView *fighterBPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *fighterBNameLabel;


@end

@implementation TBAFightTableViewCell

- (void)setFight:(Fight *)fight
{
    _fight = fight;
    [self.fighterAPictureImageView setImageWithURL:[NSURL URLWithString:_fight.boxerA.thumbnailPictureURL]
                                  placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [self.fighterANameLabel setText:[self displayNameForBoxer:_fight.boxerA]];
    
    switch (_fight.state) {
        case TBAFightStateUpcoming: {
            [self.resultLabel setText:@"vs"];
            break;
        }
            
        case TBAFightStateInProgress: {
            [self.resultLabel setText:@"vs"];
            break;
        }
            
        case TBAFightStateDraw: {
            [self.resultLabel setText:@"drew"];
            break;
        }
            
        case TBAFightStateDecision: {
            [self.resultLabel setText:@"def."];
            break;
        }
            
        case TBAFightStateKO: {
            [self.resultLabel setText:@"KO"];
            break;
        }
            
        default:
            break;
    }
    
    [self.fighterBPictureImageView setImageWithURL:[NSURL URLWithString:_fight.boxerB.thumbnailPictureURL]
                                  placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [self.fighterBNameLabel setText:[self displayNameForBoxer:_fight.boxerB]];
}

- (NSString *)displayNameForBoxer:(Boxer *)boxer
{
    return [NSString stringWithFormat:@"%@. %@",boxer.firstName,boxer.lastName];
}

- (void)layoutSubviews
{
    self.fighterAPictureImageView.layer.cornerRadius = 22.0;
    self.fighterBPictureImageView.layer.cornerRadius = 22.0;
}

@end
