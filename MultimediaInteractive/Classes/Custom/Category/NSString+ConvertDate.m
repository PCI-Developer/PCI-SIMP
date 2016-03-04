//
//  NSString+ConvertDate.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/23.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "NSString+ConvertDate.h"
#import <objc/runtime.h>





@implementation NSString (ConvertDate)


+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
    });
    return formatter;
}



+ (NSString *)stringWithDate:(NSDate *)date {
    
    [[self dateFormatter] setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [[self dateFormatter] stringFromDate:date];
    return dateString;
}


+ (NSString *)stringOnlyTimeWithDate:(NSDate *)date dateFormat:(NSString *)format {
    [[self dateFormatter] setDateFormat:format];
    NSString *dateString = [[self dateFormatter] stringFromDate:date];
    return dateString;
}

@end
