//
//  Decision.h
//  boxfan
//
//  Created by Chris Tibbs on 1/18/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Boxer.h"

@interface Decision : NSObject

@property (nonatomic) NSInteger decisionID;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Fight *fight;
@property (nonatomic,strong) Boxer *winner;
@property (nonatomic,strong) Boxer *loser;

-(instancetype)initWithRecentFightDisplayDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithDisplayedUserView:(NSDictionary *)dictionary;

-(NSString *)usersDisplayViewRepresentation;

@end
