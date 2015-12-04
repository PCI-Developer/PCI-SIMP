//
//  VolumnSlider.h
//  slideViewTest
//
//  Created by 吴非凡 on 15/10/19.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  自定义Slider,用于音量调节
 */
@interface WFFVolumeSlider : UISlider

/**
 *  按钮高度
 */
@property (nonatomic, assign) IBInspectable CGFloat trackHeight;

/**
 *  最小一侧的图片
 */
@property (nonatomic, strong) IBInspectable UIImage *minimumTrackImage;

/**
 *  最大一侧的图片
 */
@property (nonatomic, strong) IBInspectable UIImage *maximumTrackImage;

/**
 *  按钮图片
 */
@property (nonatomic, strong) IBInspectable UIImage *thumbImage;
@end
