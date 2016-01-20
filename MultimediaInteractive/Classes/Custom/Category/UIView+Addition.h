//
//  CALayer+Addition.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 16/1/20.
//  Copyright © 2016年 东方佳联. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

/* 
 * 附加层
 * 如设备-灯 的光圈
 */
@interface UIView (Addition)

// 附加层的图片
@property (nonatomic, strong) UIImage *additionImage;

// 附加层的缩放 取值:0 - 1  【附加层最大为默认层的两倍 1 + additionScale】
@property (nonatomic, assign) CGFloat additionScale;



@end
