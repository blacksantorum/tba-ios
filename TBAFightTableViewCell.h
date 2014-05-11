//
//  TBAFightTableViewCell.h
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Fight;

@interface TBAFightTableViewCell : UITableViewCell

@property (nonatomic, strong) Fight *fight; // fight to be displayed in cell

@end
