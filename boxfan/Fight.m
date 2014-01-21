//
//  Fight.m
//  boxfan
//
//  Created by Chris Tibbs on 12/15/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import "Fight.h"
#import "Boxer.h"

@interface Fight() {
    NSDictionary *_dictionary;
}

@end

@implementation Fight

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@",self.fightID,self.date,self.weight,self.location,self.rounds,self.winnerID,self.stoppage ? @"KO" : @"decision"];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _dictionary = dictionary;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [formatter dateFromString:[dictionary objectForKey:@"date"]];
        
        _fightID = [dictionary objectForKey:@"id"];
        _date = date;
        _weight = [dictionary objectForKey:@"weight"];
        _location = [dictionary objectForKey:@"location"];
        
       // NSArray *boxers = [dictionary objectForKey:@"boxers"];
        
       // _boxers = boxers;
        _rounds = [dictionary objectForKey:@"rounds"];
        _winnerID = [dictionary objectForKey:@"winner_id"];
        
        NSString *stoppageNumber = [dictionary objectForKey:@"stoppage"];
        if (![stoppageNumber isKindOfClass:[NSNull class]]) {
            if ([stoppageNumber.description isEqualToString:@"1"]) {
                self.stoppage = YES;
            } else {
                self.stoppage = NO;
            }
        }
    }
    return self;
}

-(NSString *)titleForScheduleView
{
    NSString *title = [[NSString alloc] init];
    
    Boxer *aSide = [self.boxers objectAtIndex:0];
    Boxer *bSide = [self.boxers objectAtIndex:1];
    
     // we want "<A-side boxer> - <B-side boxer>"
    title = [NSString stringWithFormat:@"%@ - %@",[aSide lastName],[bSide lastName]];
    
    return title;
}

-(NSString *)titleForRecentFightsView
{
    NSString *title = [[NSString alloc] init];
    
    Boxer *winner = [[Boxer alloc] init];
    Boxer *loser = [[Boxer alloc] init];
    for (Boxer *b in self.boxers) {
        if ([b.boxerID.description isEqualToString:self.winnerID.description]) {
            winner = b;
        } else {
            loser = b;
        }
    }
    
    if (self.stoppage) {
        title = [NSString stringWithFormat:@"%@ KO %@",winner.lastName,loser.lastName];
    } else {
        title = [NSString stringWithFormat:@"%@ def. %@",winner.lastName,loser.lastName];
    }
    
    return title;
}

@end
