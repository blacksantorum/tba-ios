//
//  TBARailsClient.h
//  boxfan
//
//  Created by Chris Tibbs on 4/29/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Place.h"

@protocol TBARailsClientDelegate;

@interface TBARailsClient : AFHTTPSessionManager

@property (nonatomic, weak) id<TBARailsClientDelegate>delegate;

+ (TBARailsClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

- (void)fetchUpcomingFights;
- (void)fetchRecentFights;
- (void)addPlace:(Place *)place forUser:(User *)user withDelegate:(id<TBARailsClientDelegate>)delegate;

@end

@protocol TBARailsClientDelegate <NSObject>

@optional

- (void)TBARailsClient:(TBARailsClient *)client didUpdateWithFights:(id)fights;
- (void)TBARailsClient:(TBARailsClient *)client didFailWithError:(NSError *)error;

- (void)TBARailsClient:(TBARailsClient *)client didAddPlace:(id)place;

@end
