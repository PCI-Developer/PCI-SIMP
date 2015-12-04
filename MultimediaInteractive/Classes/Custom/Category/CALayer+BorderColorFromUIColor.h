//
//  CALayer+BorderColorFromUIColor.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/17.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (BorderColorFromUIColor)

/**
 *  XIB中 , 通过keyPath设置边框颜色
 */
@property (nonatomic, strong) UIColor *borderColorFromUIColor;

@end
