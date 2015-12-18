//
//  NSObject+CheckNull.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/12/17.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "NSObject+CheckNull.h"

@implementation NSObject (CheckNull)

- (BOOL)checkNull
{
    if (self == nil) {
        return YES;
    }
    if (self == NULL) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([self isKindOfClass:[NSString class]]) {
        NSString *selfStr = (NSString *)self;
        if ([[selfStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        {
            return YES;
        }
        if ([selfStr isEqualToString:@"(null)"]) {
            return YES;
        }
    }
    return NO;
}
@end
