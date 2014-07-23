//
//  Place.m
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "Place.h"

@interface Place ()

- (NSDictionary *)addressFromFormattedAddressString:(NSString *)string;

@end

@implementation Place

@synthesize coordinate = _coordinate;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _name = [dictionary objectForKey:@"name"];
        _placeID = [dictionary objectForKey:@"id"];
        
        CGFloat lat = [[dictionary objectForKey:@"latitude"] floatValue];
        CGFloat lon = [[dictionary objectForKey:@"longitude"] floatValue];
        
         NSLog(@"lattttitude %f lonnnngitude %f",lat,lon);
        _coordinate = CLLocationCoordinate2DMake(lat,lon);
        
        _address = dictionary[@"address"];
        _city = dictionary[@"city"];
        _state = dictionary[@"state"];
        _title = _name;
        _subtitle = [NSString stringWithFormat:@"%@, %@",_address, _city];
    }
    return self;
}

- (instancetype)initWithMKMapItem:(MKMapItem *)item
{
    if (self = [super init]) {
        NSDictionary *address = item.placemark.addressDictionary;
        _name = address[@"Name"];
        _address = address[@"Street"];
        _city = address [@"City"];
        _state = address [@"State"];
        _zip = address [@"ZIP"];
    }
    return self;
}

- (NSDictionary *)addressFromFormattedAddressString:(NSString *)string;
{
    NSArray *array = [string componentsSeparatedByString:@", "];
    
    NSString *country = [[array lastObject] description];
    
    NSLog(@"%@",country);
    NSLog(@"United States");
    
    if (([country rangeOfString:@"United States"].location != NSNotFound) && [array count] == 4) {
        NSLog(@"I'm making a dictionary");
        return @{@"address":array[0], @"city":array[1], @"state":array[2], @"country":array[3]};
    }
    else
        return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %f, %f", self.name, self.address, self.city, self.state, self.coordinate.latitude, self.coordinate.longitude];
}

@end
