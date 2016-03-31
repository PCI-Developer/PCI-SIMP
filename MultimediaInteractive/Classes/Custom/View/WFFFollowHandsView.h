//
//  WFFFollowHandsView.h
//  Custom
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFFFollowHandsView;
@class DeviceCollectionViewCell;
@class DeviceForUser;
/**
 *  代理事件
 */
@protocol WFFFollowHandsViewDelegate <NSObject>
@optional
- (void)followHandsView:(WFFFollowHandsView *)followHandsView beginMoveWithHandsPointInSuperView:(CGPoint)handsPointInSuperView;
- (void)followHandsView:(WFFFollowHandsView *)followHandsView movingWithHandsPointInSuperView:(CGPoint)handsPointInSuperView;
- (void)followHandsView:(WFFFollowHandsView *)followHandsView endMoveWithHandsPointInSuperView:(CGPoint)handsPointInSuperView;

- (void)followHandsView:(WFFFollowHandsView *)followHandsView cancelMoveWithHandsPointInSuperView:(CGPoint)handsPointInSuperView;

- (void)clickFollowHandsView:(WFFFollowHandsView *)followHandsView;

- (void)longPressFollowHandsView:(WFFFollowHandsView *)followHandsView gr:(UILongPressGestureRecognizer *)gr;
@end

/**
 *  跟随鼠标移动的view。可以获取移动过程中的视图的中心点位置。
 */
@interface WFFFollowHandsView : UIView

#pragma mark - 属性
/**
 *  移动时候的透明度
 */
@property (nonatomic, assign) CGFloat alphaForMove;

@property (nonatomic, assign) id <WFFFollowHandsViewDelegate> delegate;

/**
 *  是否接收平移手势
 */
@property (nonatomic, assign) BOOL canMove;

/**
 *  是否接收轻拍手势
 */
@property (nonatomic, assign) BOOL canClick;

/**
 *  是否接收长按手势
 */
@property (nonatomic, assign) BOOL canLongPress;


/**
 *  旋转弧度
 */
@property (nonatomic, assign) CGFloat rotationRadian;

#pragma mark - 自定义方法
/**
 *  平移手势
 *
 *  @return 平移手势
 */
- (UIPanGestureRecognizer *)panGR;

/**
 *  设置是否显示边框颜色
 *
 *  @param isShow YES:显示,NO:不显示
 *  @param color  边框颜色
 */
- (void)showBorderColor:(BOOL)isShow color:(UIColor *)color;


#pragma mark 手动调用移动
/**
 *  手动调用移动,执行代理,记录当前点和返回点,更新透明度
 *
 *  @param gr 手势
 */
- (void)beginMoveByGR:(UIGestureRecognizer *)gr;

/**
 *  手动调用移动,执行代理,更新透明度
 *
 *  @param gr 手势
 */
- (void)moveByGR:(UIGestureRecognizer *)gr;

/**
 *  手动调用移动,执行代理,更新透明度
 *
 *  @param gr 手势
 */
- (void)endMoveByGR:(UIGestureRecognizer *)gr;

- (void)beginRotation;
- (void)endRotation;
#pragma mark - 便利构造器
#pragma mark 出现可移动view[根据cell的imageView的位置出现. 根据device的id设置tag]
+ (WFFFollowHandsView *)followHandsViewWithWidth:(CGFloat)width height:(CGFloat)height deviceCell:(DeviceCollectionViewCell *)cell device:(DeviceForUser *)device onView:(UIView *)view;
#pragma mark 出现随机的view(随机生成在父view上,根据device的id设置tag)
+ (WFFFollowHandsView *)followHandsViewByRandomPositionWithWidth:(CGFloat)width height:(CGFloat)height device:(DeviceForUser *)device onView:(UIView *)view;
#pragma mark 按顺序出现view(根据当前num的序号,决定位置,根据device的id设置tag)
+ (WFFFollowHandsView *)followHandsViewByOrderWithWidth:(CGFloat)width height:(CGFloat)height device:(DeviceForUser *)device onView:(UIView *)view num:(NSInteger)num;

@end
