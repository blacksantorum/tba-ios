//
//  TBARailsClient.h
//  boxfan
//
//  Created by Chris Tibbs on 4/29/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@protocol TBARailsClientDelegate;

@interface TBARailsClient : AFHTTPSessionManager

@property (nonatomic, weak) id<TBARailsClientDelegate>delegate;

+ (TBARailsClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

- (void)fetchUpcomingFights;
- (void)fetchRecentFights;

@end

@protocol TBARailsClientDelegate <NSObject>

@optional

- (void)TBARailsClient:(TBARailsClient *)client didUpdateWithFights:(id)fights;
- (void)TBARailsClient:(TBARailsClient *)client didFailWithError:(NSError *)error;

@end
