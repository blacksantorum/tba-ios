//
//  Comment.m
//  boxfan
//
//  Created by Chris Tibbs on 1/24/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _commentID = [[dictionary objectForKey:@"id"] integerValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *date = [formatter dateFromString:[dictionary objectForKey:@"created_at"]];
        _date = date;
        _content = [dictionary objectForKey:@"body"];
        _author = [[User alloc] initWithListOfUsersDictionary:[dictionary objectForKey:@"user"]];
        _jabs = [[dictionary objectForKey:@"votes"] integerValue];
        NSString *liked = [dictionary objectForKey:@"liked"];
        
        if ([liked isEqualToString:@"true"]) {
            _isJabbedByLoggedInUser = YES;
        } else {
            _isJabbedByLoggedInUser = NO;
        }
    }
    return self;
}

- (NSComparisonResult)compare:(Comment *)otherComment
{
    return self.jabs < otherComment.jabs;
}

@end
