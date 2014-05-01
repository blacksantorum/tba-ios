//
//  TBATwitterClient.m
//  boxfan
//
//  Created by Chris Tibbs on 4/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBATwitterClient.h"

static NSString * const TBATwitterURLString = @"https://api.twitter.com/oauth/";

@implementation TBATwitterClient

+ (TBATwitterClient *)sharedClient
{
    static TBATwitterClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:TBATwitterURLString]];
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

- (void)sendRequestForTwitterRequestToken
{
    
}

- (void)sendRequestForTwitterAccessToken
{
    
}

@end
