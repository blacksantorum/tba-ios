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

- (void)signInWithBackend:(NSDictionary *)dictionary
{
    [self POST:@"signin" parameters:dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(TBARailsClient:didLoginUser:)]) {
            [self.delegate TBARailsClient:self didLoginUser:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(TBARailsClient:didFailToLogin:)]) {
            [self.delegate TBARailsClient:self didFailToLogin:error];
        }
    }];
}

- (void)fetchUpcomingFights
{
    [self GET:@"fights/future" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(TBARailsClient:didUpdateWithFights:)]) {
            [self.delegate TBARailsClient:self didUpdateWithFights:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(TBARailsClient:didFailWithError:)]) {
            [self.delegate TBARailsClient:self didFailWithError:error];
        }
    }];
}

- (void)fetchRecentFights
{
    [self GET:@"fights/past" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(TBARailsClient:didUpdateWithFights:)]) {
            [self.delegate TBARailsClient:self didUpdateWithFights:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(TBARailsClient:didFailWithError:)]) {
            [self.delegate TBARailsClient:self didFailWithError:error];
        }
    }];
}

/////////////////////////OVERRIDE GET AND POST REQUESTS TO ADD SESSION TOKEN ///////////////////////////////////////

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(NSURLSessionDataTask *, id))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([User getCurrentUser].isLoggedIn) {
        NSDictionary *dictionary = @{@"session_token" : [User getCurrentUser].sessionToken};
        if (!mutableParams) {
            mutableParams = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        } else {
            [mutableParams addEntriesFromDictionary:dictionary];
        }
    }
    return [super GET:URLString parameters:mutableParams success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([User getCurrentUser].isLoggedIn) {
        NSDictionary *dictionary = @{@"session_token" : [User getCurrentUser].sessionToken};
        if (!mutableParams) {
            mutableParams = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        } else {
            [mutableParams addEntriesFromDictionary:dictionary];
        }
    }
     NSLog(@"%@", mutableParams);
    return [super POST:URLString parameters:mutableParams success:success failure:failure];

}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([User getCurrentUser].isLoggedIn) {
        NSDictionary *dictionary = @{@"session_token" : [User getCurrentUser].sessionToken};
        if (!mutableParams) {
            mutableParams = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        } else {
            [mutableParams addEntriesFromDictionary:dictionary];
        }
    }
    return [super DELETE:URLString parameters:mutableParams success:success failure:failure];

}

@end
