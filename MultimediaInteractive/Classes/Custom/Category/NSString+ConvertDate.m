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

//
//
//+ (void)swizzleSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector {
//    Class class = [self class];
//    
//    Method originalMethod = class_getInstanceMethod(class, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//    
//    // 若已经存在，则添加会失败
//    BOOL didAddMethod = class_addMethod(class,
//                                        originalSelector,
//                                        method_getImplementation(swizzledMethod),
//                                        method_getTypeEncoding(swizzledMethod));
//    
//    // 若原来的方法并不存在，则添加即可
//    if (didAddMethod) {
//        class_replaceMethod(class,
//                            swizzledSelector,
//                            method_getImplementation(originalMethod),
//                            method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}

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
