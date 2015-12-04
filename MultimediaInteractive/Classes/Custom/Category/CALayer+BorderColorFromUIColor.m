//
//  CALayer+BorderColorFromUIColor.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/17.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "CALayer+BorderColorFromUIColor.h"

@implementation CALayer (BorderColorFromUIColor)

- (UIColor *)borderColorFromUIColor
{
    return nil;
}

- (void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor
{
    self.borderColor = borderColorFromUIColor.CGColor;
}

@end
