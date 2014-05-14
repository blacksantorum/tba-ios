//
//  FightsViewController.h
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FightsViewController : UITableViewController <TBARailsClientDelegate>

- (void)fetchFights;

- (void)TBARailsClient:(TBARailsClient *)client didUpdateWithFights:(id)fights;
- (void)TBARailsClient:(TBARailsClient *)client didFailWithError:(NSError *)error;

- (void)startSpinner;
- (void)stopSpinner;

- (void)sortDatesDescending;
- (void)sortDatesAscending;

@end
