//
//  WFFCircularSlider.h
//  Block
//
//  Created by 吴非凡 on 15/12/1.
//  Copyright © 2015年 ROBERA GELETA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSliderLeaveFocusNotification @"WFFCircularSliderLeaveFouce"
/**
 *  圆形slider.可设置取值范围,起始角度.
 *  改变值出发valueChanged, 手指离开屏幕后触发touchCancled
 */
@interface WFFCircularSlider : UIControl

/**
 *  背景图
 */
@property (nonatomic, strong) IBInspectable UIImage *backgroundImage;

/**
 *   代表音量值的图片
 */
@property (nonatomic, strong) IBInspectable UIImage *tintImage;

/**
 *  按钮图片, 大小和边距在.m文件中的宏定义中修改
 */
@property (nonatomic, strong) IBInspectable UIImage *thumbImage;

/**
 *  当前值. (当前角度 - 起始角度) / 角度范围
 */
@property (nonatomic, assign) CGFloat value;

@end
