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

- (void)sendRequestForTwitterRequestToken
{
    NSString *nonce = [TBATwitterClient st_random32Characters];
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSLog(@"%@ & %@",nonce,timeStamp);
    
    NSDictionary *header = @{@"oauth_consumer_key": @"TK2igjpRfDN283wGr77Q",
                             @"oauth_nonce": nonce,
                             @"oauth_signature_method": @"HMAC-SHA1",
                             @"oauth_timestamp":timeStamp,
                             @"oauth_version": @"1.0"};
    
    NSDictionary *params = @{@"x_auth_mode": @"reverse_auth"};
    
    NSString *authHeader = @"OAuth ";
    for (NSString *key in [header allKeys]) {
        authHeader = [authHeader stringByAppendingString:[self URLEncodedString_ch:key]];
        authHeader = [authHeader stringByAppendingString:@"="];
        authHeader = [authHeader stringByAppendingString:@"\""];
        authHeader = [authHeader stringByAppendingString:[self URLEncodedString_ch:[header valueForKey:key]]];
        authHeader = [authHeader stringByAppendingString:@"\""];
        authHeader = [authHeader stringByAppendingString:@", "];
    }
    
    authHeader = [authHeader substringToIndex:authHeader.length - 2];
    NSLog(@"%@",authHeader);
    
    NSString *baseString = @"POST&";
    baseString = [baseString stringByAppendingString:[self URLEncodedString_ch:@"https://api.twitter.com/oauth/request_token"]];
    baseString = [baseString stringByAppendingString:@"&"];
    
    NSString *parameterString = @"";
    for (NSString *key in [header allKeys]) {
        parameterString = [parameterString stringByAppendingString:[self URLEncodedString_ch:key]];
        parameterString = [parameterString stringByAppendingString:@"="];
        parameterString = [parameterString stringByAppendingString:[self URLEncodedString_ch:header[key]]];
        parameterString = [parameterString stringByAppendingString:@"&"];
    }
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",[self URLEncodedString_ch:API_SECRET],[self URLEncodedString_ch:TOKEN_SECRET]];
    
    
    
    parameterString = [parameterString substringToIndex:parameterString.length - 1];
    
    baseString = [baseString stringByAppendingString:[self URLEncodedString_ch:parameterString]];
    
    
    
    [self.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    [self POST:@"request_token" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void)sendRequestForTwitterAccessToken
{
    
}
/*
- (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
    
    return base64EncodedResult;
}
*/
- (NSString *) URLEncodedString_ch:(NSString *)string {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (NSString *)st_randomString {
    CFUUIDRef cfuuid = CFUUIDCreate (kCFAllocatorDefault);
    NSString *uuid = (__bridge_transfer NSString *)(CFUUIDCreateString (kCFAllocatorDefault, cfuuid));
    CFRelease (cfuuid);
    return uuid;
}

+ (NSString *)st_random32Characters {
    NSString *randomString = [self st_randomString];
    return [randomString substringToIndex:32];
}


@end
