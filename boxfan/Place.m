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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _name = [dictionary objectForKey:@"name"];
        _placeID = [dictionary objectForKey:@"place_id"];
        _location = CLLocationCoordinate2DMake([[dictionary valueForKeyPath:@"geometry.location.lat"] floatValue], [[dictionary valueForKeyPath:@"geometry.location.longitude"] floatValue]);
        
        NSDictionary *address = [self addressFromFormattedAddressString:(NSString *)[dictionary objectForKey:@"formatted_address"]];
        if (address) {
            _isAmerican = YES;
            _address = address[@"address"];
            _city = address[@"city"];
            _state = address[@"state"];
            _country = address[@"country"];
        } else {
            _isAmerican = NO;
        }
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
    return [NSString stringWithFormat:@"%@, %@, %@, %@", self.name, self.address, self.city, self.state];
}

@end
