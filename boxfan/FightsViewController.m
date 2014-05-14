//
//  FightsViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "FightsViewController.h"
#import "Fight.h"
#import "TBAFightTableViewCell.h"

@interface FightsViewController ()

@property (nonatomic, strong) NSArray *dates; // of NSDate objects, used as Section Headers
@property (nonatomic, strong) NSArray *fights; // of Fights, this is the data source

- (NSArray *)fightsForDate:(NSDate *)date; // Data source helper, returns an array of Fights for a particular date

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation FightsViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.spinner.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TBARailsClient sharedClient].delegate = self;
    [self fetchFights];
}

- (void)startSpinner
{
    [self.spinner startAnimating];
}

- (void)stopSpinner
{
    [self.spinner stopAnimating];
}

- (void)sortDatesAscending
{
    self.dates = [self.dates sortedArrayUsingComparator:^NSComparisonResult(NSDate *d1, NSDate *d2){
        return [d1 compare:d2];
    }];
}

- (void)sortDatesDescending
{
    self.dates = [self.dates sortedArrayUsingComparator:^NSComparisonResult(NSDate *d1, NSDate *d2){
        return [d2 compare:d1];
    }];
}

- (void)fetchFights
{
    // override in subclass
}

#pragma mark - TBARailsClient delegate

- (void)TBARailsClient:(TBARailsClient *)client didUpdateWithFights:(id)fights
{
    NSLog(@"%@",fights);
    NSMutableArray *fightsArray = [NSMutableArray array];
    NSMutableArray *datesArray = [NSMutableArray array];
    for (NSDictionary *fightDict in (NSArray *)fights) {
        Fight *f = [[Fight alloc] initWithDictionary:fightDict];
        [fightsArray addObject:f];
        [datesArray addObject:f.date];
    }
    self.fights = fightsArray;
    NSSet *datesSet = [NSSet setWithArray:datesArray];
    self.dates = [datesSet allObjects];
}

- (void)TBARailsClient:(TBARailsClient *)client didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Couldn't load fights" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

#pragma mark - Table view data source

- (NSArray *)fightsForDate:(NSDate *)date
{
    NSMutableArray *fights = [NSMutableArray array];
    
    // add the fights from self.fights that occur on that date
    for (Fight *f in self.fights) {
        if ([f.date isEqualToDate:date]) {
            [fights addObject:f];
        }
    }
    return fights;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 35)];
    [dateLabel setTextColor:[UIColor whiteColor]];
    [dateLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
    NSDate *date = self.dates[section];
    [dateLabel setText:[self sectionHeaderFormattedStringFromDate:date]];
    [headerView addSubview:dateLabel];
    return headerView;
}

- (NSString *)sectionHeaderFormattedStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    NSString *partiallyFormattedDate = [dateFormatter stringFromDate:date];
    return [partiallyFormattedDate substringWithRange:NSMakeRange(0, [partiallyFormattedDate length] - 6)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // amount of unique dates in self.fights
    return [self.dates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // amount of fights on the day that corresponds to the section header
    NSDate *date = self.dates[section];
    return [[self fightsForDate:date] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"Fight Cell";
    TBAFightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[TBAFightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSDate *date = self.dates[indexPath.section];
    cell.fight = [self fightsForDate:date][indexPath.row];
    
    return cell;
}

@end
