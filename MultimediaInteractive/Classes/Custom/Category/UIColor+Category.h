//
//  UIColor+Category.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHexColor(colorString) [UIColor colorFromHexRGB:colorString]

@interface UIColor (Category)


/**
 *  根据字符串生成颜色
 *
 *  @param inColorString 16进制的颜色字符串，如ab2345
 *
 *  @return 颜色
 */
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString;

/**
 *  根据字符串生成颜色
 *
 *  @param inColorString 16进制的颜色字符串，如ab2345
 *  @param alpha         透明度0.0-1.0
 *
 *  @return 颜色
 */
+(UIColor *)colorFromHexRGB:(NSString *)inColorString alpha:(float)alpha;

@end
