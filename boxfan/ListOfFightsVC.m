//
//  ListOfFightsVC.m
//  boxfan
//
//  Created by Chris Tibbs on 1/26/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "ListOfFightsVC.h"
#import "ScheduleFormattedDate.h"
#import "ListOfFightsCell.h"


@interface ListOfFightsVC ()

@end

@implementation ListOfFightsVC

- (NSString *)boxerNameDisplay:(Boxer *)boxer
{
    if ([boxer.firstName length] > 0) {
        return [NSString stringWithFormat:@"%@. %@",[boxer.firstName substringToIndex:1] ,boxer.lastName];
    } else {
        return boxer.lastName;
    }
}

- (NSArray *)fightDates
{
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    for (Fight *f in self.fights) {
        [dateArray addObject:f.date];
    }
    NSSet *dateSet = [NSSet setWithArray:dateArray];
    NSArray *dates = [dateSet allObjects];
    
    _fightDates = [self appropriatelySortedDateArray:dates];
    
    return _fightDates;
}

- (NSArray *)fightsForDate:(NSDate *)date
{
    NSMutableArray *fightsForDate = [[NSMutableArray alloc] init];
    
    for (Fight *f in self.fights) {
        if ([f.date isEqualToDate:date]) {
            [fightsForDate addObject:f];
        }
    }
    return fightsForDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

// store fights into an array of fights at self.fights
- (void)configureDataSource
{
    NSMutableArray *fightArray = [[NSMutableArray alloc] init];
    for (NSDictionary *fightDictionary in self.JSONarray) {
        NSLog(@"%@",fightDictionary);
        Fight *f = [[Fight alloc] initWithDictionary:fightDictionary[@"fight"]];
        NSMutableArray *boxers = [[NSMutableArray alloc] init];
        for (NSDictionary *boxerDictionary in [fightDictionary valueForKeyPath:@"fight.boxers"]){
            
            Boxer *b = [[Boxer alloc] initWithDictionary:boxerDictionary[@"boxer"]];
            [boxers addObject:b];
        
        }
        f.boxers = boxers;
        [fightArray addObject:f];
    }
    self.fights = fightArray;
}

-(NSArray *)appropriatelySortedDateArray:(NSArray *)dateArray
{
    // must override
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fightDates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *date = [self.fightDates objectAtIndex:section];
    NSArray *fightsForDate = [self fightsForDate:date];
    return fightsForDate.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *date = [self.fightDates objectAtIndex:section];
    return [ScheduleFormattedDate sectionHeaderFormattedStringFromDate:date];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"List Of Fights Cell";
    
    [self.tableView registerClass:[ListOfFightsCell class] forCellReuseIdentifier:CellIdentifier];
    
    ListOfFightsCell *cell = (ListOfFightsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ListOfFightsCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (ListOfFightsCell *)currentObject;
                break;
            }
        }
    }
    
    NSDate *date = [self.fightDates objectAtIndex:indexPath.section];
    NSArray *fightArrayAtDate = [self fightsForDate:date];
    Fight *fight = fightArrayAtDate[indexPath.row];
    
    cell.boxerALabel.text = [self boxerNameDisplay:fight.boxerA];
    [cell.boxerACountryFlag setImage:[UIImage imageNamed:fight.boxerA.country]];
    cell.boxerBLabel.text = [self boxerNameDisplay:fight.boxerB];
    [cell.boxerBCountryFlag setImage:[UIImage imageNamed:fight.boxerB.country]];
    
    if (![fight.winnerID.description isEqualToString:@"-100"] &&
        ![fight.winnerID.description isEqualToString:@"0"] &&
        ![fight.winnerID.description isEqualToString:@"-1"]) {
        if (fight.stoppage) {
            cell.resultsLabel.text = @"KO";
        } else {
            cell.resultsLabel.text = @"def";
        }
    } else if ([fight.winnerID.description isEqualToString:@"0"]) {
        cell.resultsLabel.text = @"drew";
    }
    
    // Test cell color
    
    
    if ([fight.winnerID.description isEqualToString:@"-1"]) {
        [UIView animateWithDuration:0.75 animations:^{
            cell.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:0.05];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.75 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
        }];
        cell.backgroundColor =  [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:0.05];
    }
    
    return cell;
}


@end
