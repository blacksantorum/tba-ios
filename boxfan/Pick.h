//
//  Pick.h
//  boxfan
//
//  Created by Chris Tibbs on 12/16/13.
//  Copyright (c) 2013 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Fight.h"
#import "Boxer.h"

@interface Pick : NSObject

@property (nonatomic) NSInteger pickID;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Fight *fight;
@property (nonatomic,strong) Boxer *winner;
@property (nonatomic,strong) Boxer *loser;
@property  BOOL byStoppage;

-(instancetype)initWithFightViewDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithFeedViewDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithScheduleViewDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithDisplayedUserView:(NSDictionary *)dictionary;

-(NSString *)feedRepresentation;
-(NSString *)usersDisplayViewRepresentation;

@end
