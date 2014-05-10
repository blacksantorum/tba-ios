//
//  TBATwitterClient.m
//  boxfan
//
//  Created by Chris Tibbs on 4/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBATwitterClient.h"

#define TOKEN_SECRET @"OskKE8Aei1Pa5cGeiWIREcICzNRxGrwzY5Mnp1asfaTEK"
#define API_SECRET @"0ju7zB7dl67YsReYmPosJKWVsUbTaLZFiM01CP8Fghs"

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
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        // [serializer setValue:@"reverse_auth" forHTTPHeaderField:@"x_auth_mode"];
        self.requestSerializer = serializer;
    }
    return self;
}

- (void)verify
{
    
}

@end
