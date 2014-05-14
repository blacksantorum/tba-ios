//
//  ScheduleFormattedDate.m
//  boxfan
//
//  Created by Chris Tibbs on 1/8/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "ScheduleFormattedDate.h"

@implementation ScheduleFormattedDate

+(NSString *)sectionHeaderFormattedStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    NSString *partiallyFormattedDate = [dateFormatter stringFromDate:date];
    return [partiallyFormattedDate substringWithRange:NSMakeRange(0, [partiallyFormattedDate length] - 6)];
}

@end
