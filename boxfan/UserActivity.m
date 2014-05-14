//
//  UserActivity.m
//  boxfan
//
//  Created by Chris Tibbs on 1/20/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "UserActivity.h"

@implementation UserActivity

-(instancetype)initForUserHistoryWithPickDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _activityType = PICK;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *date = [formatter dateFromString:[dictionary valueForKey:@"updated_at"]];

        _modifiedDate = date;
       
        _fight = [[Fight alloc] initWithUserHistoryDictionary:[dictionary valueForKey:@"fight"]];
        
        NSInteger winnerID = [[dictionary valueForKey:@"winner_id"] integerValue];
        
        NSString *koObj = [dictionary valueForKeyPath:@"ko"];
        NSString *ko = koObj.description;
        if ([ko isEqualToString:@"1"]) {
            _byStoppage = YES;
        } else if ([ko isEqualToString:@"0"]) {
            _byStoppage = NO;
        }
        
        for (NSDictionary *boxerDict in [dictionary valueForKeyPath:@"fight.boxers"]) {
            Boxer *boxer = [[Boxer alloc] initWithDictionary:[boxerDict valueForKey:@"boxer"]];
            if (boxer.boxerID == winnerID) {
                _winner = boxer;
            } else {
                _loser = boxer;
            }
        }
    }
    return self;
}

-(instancetype)initForUserHistoryWithDecisionDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _activityType = DECISION;
        _byStoppage = NO;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *date = [formatter dateFromString:[dictionary valueForKey:@"updated_at"]];
        
        _modifiedDate = date;
        
        _fight = [[Fight alloc] initWithUserHistoryDictionary:[dictionary valueForKey:@"fight"]];
        
        NSInteger winnerID = [[dictionary valueForKey:@"winner_id"] integerValue];
        
        for (NSDictionary *boxerDict in [dictionary valueForKeyPath:@"fight.boxers"]) {
            Boxer *boxer = [[Boxer alloc] initWithDictionary:[boxerDict valueForKey:@"boxer"]];
            if (boxer.boxerID == winnerID) {
                _winner = boxer;
            } else {
                _loser = boxer;
            }
        }
    }
    return self;
}

@end
