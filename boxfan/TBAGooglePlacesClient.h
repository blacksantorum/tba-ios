//
//  TBAGooglePlacesClient.h
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

@protocol TBAGooglePlacesClientDelegate;

@interface TBAGooglePlacesClient : AFHTTPSessionManager

+ (TBAGooglePlacesClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

- (void)fetchResultsForKeyword:(NSString *)keyword atLocation:(CLLocation *)location withDelegate:(id<TBAGooglePlacesClientDelegate>) delegate;

@end

@protocol TBAGooglePlacesClientDelegate <NSObject>

@optional

- (void)TBAGooglePlacesClient:(TBAGooglePlacesClient *)client didUpdateWithPlaces:(id)places;
- (void)TBAGooglePlacesClient:(TBAGooglePlacesClient *)client didFailWithError:(NSError *)error;

@end