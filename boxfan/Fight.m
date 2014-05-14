//
//  Fight.m
//  boxfan
//
//  Created by Chris Tibbs on 12/15/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import "Fight.h"
#import "NSDictionary+CLT.h"

@interface Fight() {
    NSDictionary *_dictionary;
}

@end

@implementation Fight

-(NSString *)description
{
    return [NSString stringWithFormat:@"%ld,%@,%ld,%@,%ld,%ld,%@",(long)self.fightID,self.date,(long)self.weight,self.location,(long)self.rounds,(long)self.winnerID,self.stoppage ? @"KO" : @"decision"];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // get the meat of the fight dictionary, with null values purged
        NSDictionary *fightDict = [(NSDictionary *)[dictionary objectForKey:@"fight"] dictionaryWithoutNullValues];
        
        _fightID = [[fightDict objectForKey:@"id"] integerValue];
        _winnerID = [[fightDict objectForKey:@"winner_id"] integerValue];
        _stoppage = [[fightDict objectForKey:@"stoppage"] boolValue];
        
        if (_winnerID == -100) {
            _state = TBAFightStateUpcoming;
        }
        else if (_winnerID == -1) {
            _state = TBAFightStateInProgress;
        }
        else if (_winnerID == 0) {
            _state = TBAFightStateDraw;
        }
        else
        {
            if (_stoppage) {
                _state = TBAFightStateKO;
            } else {
                _state = TBAFightStateDecision;
            }
        }
        
        // if the fight is over, set the Winner to be boxerA
        if (_state == TBAFightStateDecision || _state == TBAFightStateKO) {
            for (NSDictionary *boxerDict in [fightDict objectForKey:@"boxers"]) {
                Boxer *b = [[Boxer alloc] initWithDictionary:boxerDict];
                if (b.boxerID == _winnerID) {
                    _boxerA = b;
                } else {
                    _boxerB = b;
                }
            }
        } else {
            NSArray *boxers = [fightDict objectForKey:@"boxers"];
            _boxerA = [[Boxer alloc] initWithDictionary:[boxers firstObject]];
            _boxerB = [[Boxer alloc] initWithDictionary:[boxers lastObject]];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [formatter dateFromString:[fightDict objectForKey:@"date"]];
        _date = date;
        
        _weight = [[dictionary objectForKey:@"weight"] integerValue];
        _location = [dictionary objectForKey:@"location"];
        
        _rounds = [[dictionary objectForKey:@"rounds"] integerValue];
    }
    return self;
}



@end
