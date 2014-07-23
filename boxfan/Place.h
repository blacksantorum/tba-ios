//
//  Place.h
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Place : NSObject <MKAnnotation>

@property (nonatomic) BOOL isAmerican;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic,strong) NSString *zip;
@property (nonatomic, strong) NSString *country;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithMKMapItem:(MKMapItem *)item;

@end
