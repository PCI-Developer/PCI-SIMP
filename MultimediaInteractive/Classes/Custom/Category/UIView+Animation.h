//
//  UIView+Animation.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/12.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

/**
 *  利用十六进制值设置背景色
 */
@property (nonatomic, copy) IBInspectable NSString *backgroundColorFromHexColor;

/**
 *  利用图片平铺设置背景色
 */
@property (nonatomic, strong) IBInspectable UIImage *backgroundColorFromUIImage;

/**
 *  令指定view颤抖
 */
- (void)shake;

/**
 *  令指定view颤抖
 *
 *  @param duration 动画时间
 */
- (void)shakeWithDuration:(CGFloat)duration;

/**
 *  添加过场动画
 *
 *  @param type     动画类型
 *  @param subType  方向
 *  @param duration 动画时间
 *  @param key      动画的key值
 */
- (void)addTransitionWithType:(NSString *)type subType:(NSString *)subType duration:(CGFloat)duration key:(NSString *)key;

/**
 *  根据key值移除动画
 *
 *  @param key 动画的key值
 */
- (void)removeAnimationForKey:(NSString *)key;

- (void)startRotation;

- (void)stopRotation;

// 是否带转场动画的隐藏
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

// 最后一个参数。原有的方向。 0 左边 1右边
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated originPos:(NSUInteger)originPos;


// 是否带转场动画的隐藏
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completionHandle:(void (^)())completionHandle;



- (void)addSubview:(UIView *)view animated:(BOOL)animated;

- (void)addSubview:(UIView *)view animated:(BOOL)animated completionHandle:(void (^)())completionHandle;

- (void)removeFromSuperviewWithAnimated:(BOOL)animated completionHandle:(void (^)())completionHandle;

- (void)removeFromSuperviewWithAnimated:(BOOL)animated;
@end
