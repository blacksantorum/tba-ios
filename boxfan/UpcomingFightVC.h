//
//  UpcomingFightVC.h
//  boxfan
//
//  Created by Chris Tibbs on 1/8/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "FightDisplayVC.h"
#import "Fight.h"
#import "FighterPickControlsView.h"

@interface UpcomingFightVC : FightDisplayVC <ChooseFighterDelegate,UIActionSheetDelegate>

@property (strong,nonatomic) Fight *fight;
@property (strong,nonatomic) Pick *currentPick;

@end
