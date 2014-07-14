//
//  Place.h
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Place : NSObject

@property (nonatomic) BOOL isAmerican;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic) CLLocationCoordinate2D location;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
