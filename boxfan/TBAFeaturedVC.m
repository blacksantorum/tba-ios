//
//  TBAFeaturedVC.m
//  boxfan
//
//  Created by Chris Tibbs on 5/10/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBAFeaturedVC.h"

@interface TBAFeaturedVC ()

@end

@implementation TBAFeaturedVC

- (void)fetchFights
{
    [[TBARailsClient sharedClient] fetchUpcomingFights];
}


#pragma mark - TBARailsClient

- (void)TBARailsClient:(TBARailsClient *)client didUpdateWithFights:(id)fights
{
    [super TBARailsClient:client didUpdateWithFights:fights];
}

@end
