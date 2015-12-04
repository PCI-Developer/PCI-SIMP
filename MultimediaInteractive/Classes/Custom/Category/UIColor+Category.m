//
//  UIColor+Category.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)


/**
 *  根据字符串生成颜色
 *
 *  @param inColorString 16进制的颜色字符串，如ab2345
 *
 *  @return 颜色
 */
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

+(UIColor *)colorFromHexRGB:(NSString *)inColorString alpha:(float)alpha
{
    UIColor *result = [UIColor clearColor];
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
        redByte = (unsigned char) (colorCode >> 16);
        greenByte = (unsigned char) (colorCode >> 8);
        blueByte = (unsigned char) (colorCode); // masks off high bits
        result = [UIColor
                  colorWithRed: (float)redByte / 0xff
                  green: (float)greenByte/ 0xff
                  blue: (float)blueByte / 0xff
                  alpha:alpha];
    }
    return result;
}

@end
