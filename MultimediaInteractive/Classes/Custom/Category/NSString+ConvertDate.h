//
//  NSString+ConvertDate.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/23.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ConvertDate)
/**
 *  将NSDate对象转成NSString
 *
 *  @param date NSDate对象
 *
 *  @return 对应的NSString
 */
+ (NSString *)stringWithDate:(NSDate *)date;

/**
 *  将NSDate对象按照指定格式串转成NSString
 *
 *  @param date   NSDate对象
 *  @param format 格式串
 *
 *  @return 对应的NSString
 */
+ (NSString *)stringOnlyTimeWithDate:(NSDate *)date dateFormat:(NSString *)format;
@end
