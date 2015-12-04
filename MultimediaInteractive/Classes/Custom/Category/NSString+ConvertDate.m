//
//  NSString+ConvertDate.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/23.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "NSString+ConvertDate.h"

@implementation NSString (ConvertDate)

+ (NSString *)stringWithDate:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}


+ (NSString *)stringOnlyTimeWithDate:(NSDate *)date dateFormat:(NSString *)format {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end
