//
//  Fight.h
//  boxfan
//
//  Created by Chris Tibbs on 12/15/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Boxer;

typedef enum {
    TBAFightStateUpcoming,
    TBAFightStateInProgress,
    TBAFightStateDraw,
    TBAFightStateKO,
    TBAFightStateDecision
} TBAFightState;

@interface Fight : NSObject

@property (nonatomic) NSInteger fightID;
@property (nonatomic, strong) Boxer *boxerA;
@property (nonatomic, strong) Boxer *boxerB;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSInteger weight;
@property (nonatomic, strong) NSString *location;
@property (nonatomic) NSInteger rounds;
@property (nonatomic) NSInteger winnerID;
@property (nonatomic) TBAFightState state;
@property BOOL stoppage;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithUserHistoryDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithFOYDictionary:(NSDictionary *)dictionary;

- (NSString *)titleForScheduleView;
- (NSString *)titleForRecentFightsView;
- (Boxer *)boxerA;
- (Boxer *)boxerB;

@end
