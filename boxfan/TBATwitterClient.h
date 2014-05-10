//
//  TBATwitterClient.h
//  boxfan
//
//  Created by Chris Tibbs on 4/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@protocol TBATwitterClientDelegate;

@interface TBATwitterClient : AFHTTPSessionManager

@property (nonatomic, weak) id<TBATwitterClientDelegate>delegate;

+ (TBATwitterClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

- (void)verify;


@end

@protocol TBATwitterClientDelegate <NSObject>

@optional

- (void)TBATwitterClient:(TBATwitterClient *)client didVerifyWithUserDictionary:(id)userDictionary;
- (void)TBATwitterClient:(TBATwitterClient *)client didFailToVerifyWithError:(NSError *)error;

@end

