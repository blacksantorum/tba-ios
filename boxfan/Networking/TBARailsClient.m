//
//  TBARailsClient.m
//  boxfan
//
//  Created by Chris Tibbs on 4/29/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBARailsClient.h"

static NSString * const TBARailsURLString = @"http://www.theboxingapp.com/api/";

@implementation TBARailsClient

+ (TBARailsClient *)sharedClient
{
    static TBARailsClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:TBARailsURLString]];
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

- (void)fetchUpcomingFights
{
    [self GET:@"fights/past" parameters:@{@"session_token" : @"T8-5y3JoMpKqOd5HGPAAKg"} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
    }];
}

@end
