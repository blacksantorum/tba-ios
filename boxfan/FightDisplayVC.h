//
//  FightDisplayVC.h
//  boxfan
//
//  Created by Chris Tibbs on 1/8/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fight.h"
#import "Pick.h"
#import "Decision.h"
#import "BoxFanRevealController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "PickInfoCell.h"
#import "DecisionInfoCell.h"
#import "CommentCell.h"


@interface FightDisplayVC : UIViewController <UITableViewDataSource,UITableViewDataSource,ChangePickDelegate,ChangeDecisionDelegate,UIActionSheetDelegate>

@property (strong,nonatomic) AFHTTPRequestOperationManager *manager;

@property (strong,nonatomic) Fight *fight;
@property (strong,nonatomic)  User *loggedInUser;
// @property (strong,atomic) NSURL *urlForRequest;
@property (strong,nonatomic) NSDictionary *JSONdictionary;
@property (strong,nonatomic) Pick *pick;
@property (strong,nonatomic) Decision *decision;

@property (weak, nonatomic) IBOutlet UITableView *fightInfoTableView;

- (void)configureDataSource;
- (void)refresh;

// if pick, dictionary= @{@"pick":@{@"winner_id": boxer.boxerID}};
// if decision, dictionary= @{@"decision":@{@"winner_id": boxer.boxerID}};
-(void)postUserActivityDictionary:(NSDictionary *)dictionary
                      toURLString:(NSString *)url;

@end
