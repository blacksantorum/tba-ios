//
//  TBAGooglePlacesClient.m
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBAGooglePlacesClient.h"


static NSString * const GooglePlacesString = @"https://maps.googleapis.com/maps/api/place/";
// #define kGOOGLE_API_KEY @"AIzaSyCtifPaaVKXvTGV05I7guqsXRDvPdingEI"
#define kGOOGLE_API_KEY @"AIzaSyBzfUw8t9eHcWjitPr9HBtMFEVMf74iPW0"

@implementation TBAGooglePlacesClient

+ (TBAGooglePlacesClient *)sharedClient
{
    static TBAGooglePlacesClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:GooglePlacesString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)fetchResultsForKeyword:(NSString *)keyword atLocation:(CLLocation *)location withDelegate:(id<TBAGooglePlacesClientDelegate>)delegate
{
    NSDictionary *params = @{@"key":kGOOGLE_API_KEY, @"latitude":[NSNumber numberWithDouble:location.coordinate.latitude], @"longitude": [NSNumber numberWithDouble:location.coordinate.longitude], @"radius":@50000, @"query":keyword, @"types":@[@"bar",@"casino",@"establishment",@"food",@"gym",@"lodging",@"movie_theater",@"night_club",@"restaurant",@"stadium"]};
    NSLog(@"%@",[self GET:@"textsearch/json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([delegate respondsToSelector:@selector(TBAGooglePlacesClient:didUpdateWithPlaces:)]) {
            [delegate TBAGooglePlacesClient:self didUpdateWithPlaces:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([delegate respondsToSelector:@selector(TBAGooglePlacesClient:didFailWithError:)]) {
            [delegate TBAGooglePlacesClient:self didFailWithError:error];
        }
    }]);
}

@end
