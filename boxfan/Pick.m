//
//  Pick.m
//  boxfan
//
//  Created by Chris Tibbs on 12/16/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import "Pick.h"

@implementation Pick

-(instancetype)initWithFightViewDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if (![[dictionary valueForKeyPath:@"fight.pick"] isKindOfClass:[NSNull class]]) {
            NSMutableArray *boxerArray = [[NSMutableArray alloc] init];
            for (NSDictionary *boxerDict in [dictionary valueForKeyPath:@"fight.boxers"]) {
                Boxer *b = [[Boxer alloc] initWithDictionary:boxerDict[@"boxer"]];
                [boxerArray addObject:b];
            }
            
            _user = self.user;
            
            NSString *winnerID = [dictionary valueForKeyPath:@"fight.pick.winner_id"];
            Boxer *b = [boxerArray firstObject];
            /*
            if ([b.boxerID.description  isEqualToString:winnerID.description]) {
                _winner = b;
                _loser = [boxerArray lastObject];
            } else {
                _winner = [boxerArray lastObject];
                _loser = b;
            }
            */
            
            NSString *koObj = [dictionary valueForKeyPath:@"fight.pick.ko"];
            NSString *ko = koObj.description;
            if ([ko isEqualToString:@"1"]) {
                _byStoppage = YES;
            } else if ([ko isEqualToString:@"0"]) {
                _byStoppage = NO;
            }
        } else {
            self = nil;
        }
    }
    return self;
}

-(instancetype)initWithFeedViewDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        User *user = [[User alloc] initWithListOfUsersDictionary:[dictionary valueForKeyPath:@"pick.user"]];
        _user = user;
        
        NSMutableArray *boxerArray = [[NSMutableArray alloc] init];
        for (NSDictionary *boxerDict in [dictionary valueForKeyPath:@"pick.fight.boxers"]) {
            Boxer *b = [[Boxer alloc] initWithDictionary:boxerDict[@"boxer"]];
            [boxerArray addObject:b];
        }
        
        NSString *winnerID = [dictionary valueForKeyPath:@"pick.winner_id"];

        Boxer *b = [boxerArray firstObject];
        /*
        if ([b.boxerID.description  isEqualToString:winnerID.description]) {
            _winner = b;
            _loser = [boxerArray lastObject];
        } else {
            _winner = [boxerArray lastObject];
            _loser = b;
        }
        */
        Fight *fight = [[Fight alloc] initWithDictionary:[dictionary valueForKeyPath:@"pick.fight"]];
        _fight = fight;
    }
    return self;
}

-(NSString *)feedRepresentation
{
    NSString *byStoppageString = [[NSString alloc] init];
    if (!self.byStoppage) {
        byStoppageString = @"by decision";
    } else {
        byStoppageString = @"by KO";
    }
    
    NSString *feedRep = [NSString stringWithFormat:@"%@ picked %@ over %@ %@",self.user.name,self.winner.lastName,self.loser.lastName,byStoppageString];
    
    return feedRep;
}

-(NSString *)usersDisplayViewRepresentation
{
    NSString *byStoppageString = [[NSString alloc] init];
    if (!self.byStoppage) {
        byStoppageString = @"by decision";
    } else {
        byStoppageString = @"by KO";
    }
    
    return [NSString stringWithFormat:@"Picked %@ over %@ %@",self.winner.lastName,self.loser.lastName,byStoppageString];
}

-(instancetype)initWithScheduleViewDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        Fight *f = [[Fight alloc] init];
        f.fightID = [dictionary valueForKeyPath:@"pick.fight_id"];
        _fight = f;
        
        Boxer *w = [[Boxer alloc] init];
        w.boxerID = [dictionary valueForKeyPath:@"pick.winner_id"];
        _winner = w;
    }
    return self;
}

-(instancetype)initWithDisplayedUserView:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        /*
        _pickID = [dictionary valueForKeyPath:@"pick.id"];
        Fight *fight = [[Fight alloc] init];
        fight.fightID = [dictionary valueForKeyPath:@"pick.fight_id"];
        _fight = fight;
        
        NSString *winnerID = [dictionary valueForKeyPath:@"pick.winner_id"];
        
        for (NSDictionary *boxerDict in [dictionary valueForKeyPath:@"pick.fight.boxers"]) {
            Boxer *b = [[Boxer alloc] initWithDictionary:[boxerDict valueForKey:@"boxer"]];
            if ([b.boxerID.description isEqualToString:winnerID.description]) {
                _winner = b;
            } else {
                _loser = b;
            }
        }
        */
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@,",self.user, self.fight, self.winner, self.loser];
}

@end
