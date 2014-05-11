//
//  FightsViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "FightsViewController.h"
#import "Fight.h"

@interface FightsViewController ()

@property (nonatomic, strong) NSArray *dates; // of NSDate objects, used as Section Headers
@property (nonatomic, strong) NSArray *fights; // of Fights, this is the data source

- (NSArray *)fightsForDate:(NSDate *)date; // Data source helper, returns an array of Fights for a particular date

@end

@implementation FightsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TBARailsClient sharedClient].delegate = self;
    [self fetchFights];
}

- (void)fetchFights
{
    // override in subclass
}

#pragma mark - TBARailsClient delegate

- (void)TBARailsClient:(TBARailsClient *)client didUpdateWithFights:(id)fights
{
    NSLog(@"%@",fights);
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

@end
