//
//  FightDisplayVC.m
//  boxfan
//
//  Created by Chris Tibbs on 1/8/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "FightDisplayVC.h"
#import "TopCommentCell.h"
#import "FightInfoCell.h"
#import "ScheduleFormattedDate.h"
#import "MostJabbedCommentsDisplayVC.h"
#import "RecentFightDisplayViewController.h"
#import "UpcomingFightViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import "boxfanAppDelegate.h"
#import "NoCommentsCell.h"



@interface FightDisplayVC () {
    UIActivityIndicatorView *spinner;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentTextField;

// labels
@property (weak, nonatomic) IBOutlet UILabel *boxerAFirstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *boxerALastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *boxerBFirstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *boxerBLastNameLabel;

// pick, dictionary percentages
@property (strong,nonatomic) NSDictionary *boxersToPickPercentages;
@property (strong,nonatomic) NSDictionary *boxersToDecisionPercentages;

@property (strong,nonatomic) NSArray *comments;

@end

@implementation FightDisplayVC

#pragma mark - Custom cells

// fight info

- (NoCommentsCell *)noCommentsCellFor:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"No Comments Cell";
    
    [tableView registerClass:[NoCommentsCell class] forCellReuseIdentifier:CellIdentifier];
    
    NoCommentsCell *cell = (NoCommentsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (NoCommentsCell *)currentObject;
                break;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (TopCommentCell *)topCommentCellFor:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Comment Cell";
    
    [tableView registerClass:[TopCommentCell class] forCellReuseIdentifier:CellIdentifier];
    
    TopCommentCell *cell = (TopCommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TopCommentCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (TopCommentCell *)currentObject;
                break;
            }
        }
    }
    
    Comment *comment = self.comments[0];
    
    cell.comment = comment;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *profileImage = [self imageForURL:[NSURL URLWithString:comment.author.profileImageURL]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [cell.userProfileImage setImage:profileImage];
        });
    });
    
    cell.twitterHandleLabel.text = comment.author.handle;
    cell.commentContentTextView.text = nil;
    cell.commentContentTextView.text = comment.content;
    
    TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
    
    // formatted time interval from comment date to now
    cell.commentDateTimeLabel.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:comment.date];
    cell.totalJabsLabel.text = [NSString stringWithFormat:@"%d",(int)comment.jabs];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UIImage *)imageForURL:(NSURL *)imageURL
{
    NSData *data = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:data];
}

- (FightInfoCell *)fightInfoCellFor:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Fight Info Cell";
    
    [self.fightInfoTableView registerClass:[FightInfoCell class] forCellReuseIdentifier:CellIdentifier];
    
    FightInfoCell *cell = (FightInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Fight Info Cell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (FightInfoCell *)currentObject;
                break;
            }
        }
    }
    
    cell.dateLabel.text = [ScheduleFormattedDate sectionHeaderFormattedStringFromDate:self.fight.date];
    cell.locationLabel.text = self.fight.location;

    cell.roundsWeightLabel.text = [NSString stringWithFormat:@"%@ rounds at %@",self.fight.rounds,[self.fight.weight.description isEqualToString:@"0"] ? @"200+":self.fight.weight];
    cell.fight = self.fight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (PickInfoCell *)pickInfoCellFor:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Pick Info Cell";
    
    [self.fightInfoTableView registerClass:[PickInfoCell class] forCellReuseIdentifier:CellIdentifier];
    
    PickInfoCell *cell = (PickInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Pick Info Cell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (PickInfoCell *)currentObject;
                break;
            }
        }
    }
    
    if (self.pick) {
        cell.currentPickDescriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:[self currentPickDescriptionLabelRepresentationForPick:self.pick]];
    } else {
        cell.currentPickDescriptionLabel.text = @"";
    }
    
    if (![self.fight.winnerID.description isEqualToString:@"-100"]) {
        [cell.makePickButton removeFromSuperview];
        if (!self.pick) {
            cell.yourPickLabel.text = @"";
        } else {
            cell.yourPickLabel.text = @"Your pick:";
            
            if (![self.pick.winner.boxerID.description isEqualToString:self.fight.winnerID.description] && ![self.fight.winnerID.description isEqualToString:@"-1"]) {
                NSMutableAttributedString *wrongPick = [[NSMutableAttributedString alloc] initWithString:[self currentPickDescriptionLabelRepresentationForPick:self.pick]attributes:@{NSStrikethroughStyleAttributeName:
                                                                                                                                                            [NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
            
                
                [cell.currentPickDescriptionLabel setAttributedText:wrongPick];
            }
        }
    }
    
    NSString *pickPercentageA = self.boxersToPickPercentages[self.fight.boxerA.boxerFullName];
    NSString *pickPercentageB = self.boxersToPickPercentages[self.fight.boxerB.boxerFullName];
        
    if ([pickPercentageB length]) {
        cell.boxerAPercentage = [pickPercentageA floatValue];
        cell.boxerBPercentage = [pickPercentageB floatValue];
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (DecisionInfoCell *)decisionInfoCellFor:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Decision Info Cell";
    
    [self.fightInfoTableView registerClass:[DecisionInfoCell class] forCellReuseIdentifier:CellIdentifier];
    
    DecisionInfoCell *cell = (DecisionInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Decision Info Cell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (DecisionInfoCell *)currentObject;
                break;
            }
        }
    }
    
    if (self.decision) {

        cell.currrentDecisionLabel.text = [self decisionCellButtonRepresentationForDecision:self.decision];
    } else {
        cell.currrentDecisionLabel.text = @"";
    }
    
    NSString *decisionPercentageA = self.boxersToDecisionPercentages[self.fight.boxerA.boxerFullName];
    NSString *decisionPercentageB = self.boxersToDecisionPercentages[self.fight.boxerB.boxerFullName];
    
    if ([decisionPercentageB length]) {
        cell.boxerAPercentage = [decisionPercentageA floatValue];
        cell.boxerBPercentage = [decisionPercentageB floatValue];
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSString *)currentPickDescriptionLabelRepresentationForPick:(Pick *)pick
{
    return [NSString stringWithFormat:@"%@ %@",pick.winner.lastName,pick.byStoppage ? @"by KO" : @"by dec"];
}

-(NSString *)decisionCellButtonRepresentationForDecision:(Decision *)decision
{
    return [NSString stringWithFormat:@"%@ won",decision.winner.lastName];
}

-(AFHTTPRequestOperationManager *)manager
{
    return [AFHTTPRequestOperationManager manager];
}

-(User *)loggedInUser
{
    BoxFanRevealController *bfrc= (BoxFanRevealController *)self.revealController;
    return bfrc.loggedInUser;
}

- (void)addActivityViewIndicator
{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:spinner];
    spinner.center = self.view.center;
}

-(void)refresh
{
    [spinner startAnimating];
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:[URLS urlForUsersCurrentPickForFight:self.fight]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                            message:@"Please check your data connection"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSError *error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
            
            } else {
                self.JSONdictionary = (NSDictionary *)object;
                [self configureDataSource];
                
            }
        }
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        [spinner stopAnimating];
    }];
}

-(void)configureDataSource
{
    NSDictionary *pickDictionary = self.JSONdictionary;
    self.pick = [[Pick alloc] initWithFightViewDictionary:pickDictionary];
    
    NSDictionary *decisionDictionary = [self.JSONdictionary valueForKeyPath:@"fight.decision"];
    
    if (![JSONDataNullCheck isNull:decisionDictionary]) {
        self.decision = [[Decision alloc] initWithRecentFightDisplayDictionary:decisionDictionary];
        self.decision.fight = self.fight;
        self.decision.user = self.loggedInUser;
        for (Boxer *b in self.fight.boxers) {
            if ([b.boxerID.description isEqualToString:self.decision.winner.boxerID.description]) {
                self.decision.winner = b;
            } else {
                self.decision.loser = b;
            }
        }
    }
    
    NSMutableDictionary *boxersToPicksPercentages = [[NSMutableDictionary alloc] init];
    for (NSDictionary *boxerDict in [self.JSONdictionary valueForKeyPath:@"fight.boxers"]) {
        NSString *boxerName = [NSString stringWithFormat:@"%@ %@",[boxerDict valueForKeyPath:@"boxer.first_name"],[boxerDict valueForKeyPath:@"boxer.last_name"]];
        NSString *pickPercentage = [boxerDict valueForKeyPath:@"boxer.percent_pick"];
        [boxersToPicksPercentages addEntriesFromDictionary:@{boxerName:pickPercentage.description}];
    }
    self.boxersToPickPercentages = boxersToPicksPercentages;
    
    NSMutableDictionary *boxersToDecisionPercentages = [[NSMutableDictionary alloc] init];
    for (NSDictionary *boxerDict in [self.JSONdictionary valueForKeyPath:@"fight.boxers"]) {
        NSString *boxerName = [NSString stringWithFormat:@"%@ %@",[boxerDict valueForKeyPath:@"boxer.first_name"],[boxerDict valueForKeyPath:@"boxer.last_name"]];
        NSString *decisionPercentage = [boxerDict valueForKeyPath:@"boxer.percent_decision"];
        [boxersToDecisionPercentages addEntriesFromDictionary:@{boxerName:decisionPercentage.description}];
    }
    self.boxersToDecisionPercentages = boxersToDecisionPercentages;
    
    NSMutableArray *commentsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *commentDict in [self.JSONdictionary valueForKeyPath:@"fight.comments"]) {
        Comment *c = [[Comment alloc] initWithDictionary:[commentDict objectForKey:@"comment"]];
        [commentsArray addObject:c];
    }
    
    self.comments = [commentsArray sortedArrayUsingSelector:@selector(compare:)];
     
    [self.fightInfoTableView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLabels];
    [self addActivityViewIndicator];
    [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"connectionRestored" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.fightInfoTableView reloadData];
}

- (void)setLabels
{
    self.boxerAFirstNameLabel.text = self.fight.boxerA.firstName;
    self.boxerALastNameLabel.text = self.fight.boxerA.lastName;
    self.boxerBFirstNameLabel.text = self.fight.boxerB.firstName;
    self.boxerBLastNameLabel.text = self.fight.boxerB.lastName;
    
    if (![self.fight.winnerID.description isEqualToString:@"-100"] && ![self.fight.winnerID.description isEqualToString:@"0"]) {
        if (self.fight.stoppage) {
            self.resultLabel.text = @"KO";
        } else {
            self.resultLabel.text = @"def.";
        }
    } else if ([self.fight.winnerID.description isEqualToString:@"0"]) {
        self.resultLabel.text = @"drew";
    }
    else {
        self.resultLabel.text = @"-";
    }
}

-(void)postUserActivityDictionary:(NSDictionary *)dictionary toURLString:(NSString *)url
{
    [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [self.manager POST:url parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
   
        [self refresh];
        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. Can't connect."
                                                        message:@"Your update could not be completed. Please check your data connection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        [(boxfanAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Top Comment";
    }
    else if (section == 1)
    {
        return @"Fight Info";
    }
    else if (section == 2)
    {
        return @"Predictions";
    }
    else
    {
        return @"Decisions";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.comments count] > 0) {
            return [self topCommentCellFor:tableView forIndexPath:indexPath];
        } else {
            return [self noCommentsCellFor:tableView forIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 1) {
        FightInfoCell *cell = [self fightInfoCellFor:tableView forIndexPath:indexPath];
        cell.delegate = self;
        
        if ([self isKindOfClass:[UpcomingFightViewController class]]) {
            [cell.FOYButton removeFromSuperview];
        }
        if ([self isKindOfClass:[RecentFightDisplayViewController class]]) {
            if ([self.fight.fightID.description isEqualToString:self.loggedInUser.foy.fightID.description]) {
                [cell.FOYButton setTitle:@"This is your FOY" forState:UIControlStateNormal];
                [cell.FOYButton setTitle:@"This is your FOY" forState:UIControlStateDisabled];
                cell.FOYButton.enabled = NO;
            }
        }
        return cell;
    }
    else if (indexPath.section == 2) {
        return [self pickInfoCellFor:tableView forIndexPath:indexPath];
    }
    else {
        return [self decisionInfoCellFor:tableView forIndexPath:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showComments"]) {
        MostJabbedCommentsDisplayVC *controller = (MostJabbedCommentsDisplayVC *)segue.destinationViewController;
        
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Fight"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[self navigationItem] setBackBarButtonItem:newBackButton];
        
        controller.title = self.fight.titleForScheduleView;
        controller.fight = self.fight;
    }
}

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath {
    // CGFloat textViewWidth = calculationView.frame.size.width;
    // if (!calculationView.attributedText) {
    // This will be needed on load, when the text view is not inited yet
    
    UITextView *calculationView = [[UITextView alloc] init];
    
    Comment *comment = self.comments[indexPath.row];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:comment.content attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    calculationView.attributedText = string;
    CGFloat textViewWidth = 238.0;
    // }
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.comments count] > 0) {
            CGFloat calculatedHeight = [self textViewHeightForRowAtIndexPath:indexPath] + 50;
            if (calculatedHeight < 90) {
                return 90;
            } else {
                return calculatedHeight;
            }
        } else {
            return 56.0;
        }
    } else if (indexPath.section == 1) {
        return 66.0;
    } else {
        return 302.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MostJabbedCommentsDisplayVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"jabbed"];
        controller.title = self.fight.titleForScheduleView;
        controller.fight = self.fight;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionRestored" object:nil];
}

@end
