//
//  WFFDropdownList.h
//  Custom
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ListOrientationUp,
    ListOrientationDown
} ListOrientation;

@class WFFDropdownList;

/**
 *  下啦列表代理
 */
@protocol WFFDropdownListDelegate <NSObject>

@optional
#pragma mark - 展开下拉列表后，点击某项的代理方法
- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex;

@end

/**
 *  下啦列表
 *  支持XIB布局
 *  横竖平适配的时候,在屏幕旋转通知及viewDidLayoutSubviews两个方法内,手动调用即可
 *  [self.dropDownList layoutIfNeeded];
 *  [self.dropDownList updateSubViews];
 */
@interface WFFDropdownList : UIView

/**
 *  设置或获取当前选中项
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 *  设置下拉列表最多可显示几项
 */
@property (nonatomic, assign) IBInspectable NSInteger maxCountForShow;

/**
 *  代理
 */
@property (nonatomic, assign) id <WFFDropdownListDelegate> delegate;

/**
 *  初始化方法
 *
 *  @param frame frame
 *  @param array 下拉列表数组
 *
 *  @return 下拉列表对象
 */
- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array;

@property (nonatomic, strong) IBInspectable UIColor *textColor;

@property (nonatomic, strong) IBInspectable UIColor *tableTextColor;

@property (nonatomic, strong) IBInspectable UIFont *font;

@property (nonatomic, strong) NSArray *dataArray;

/**
 *  弹出的下啦列表的方向(上或者下) - 默认下
 */
@property (nonatomic, assign) ListOrientation listOrientation;

/**
 *  右边图片
 */
@property (nonatomic, strong) IBInspectable UIImage *rightImage;

/**
 *  出现下啦列表时,右边图片
 */
@property (nonatomic, strong) IBInspectable UIImage *rightImageSelected;

/**
 *  背景图片
 */
@property (nonatomic, strong) IBInspectable UIImage *backgroundImage;

/**
 *  出现下啦列表时的背景图片
 */
@property (nonatomic, strong) IBInspectable UIImage *backgroundImageSelected;

/**
 *  下啦列表背景图片
 */
@property (nonatomic, strong) IBInspectable UIImage *listBackgroundImage;

/**
 *  下啦列表单元格背景色(图片平铺)
 */
@property (nonatomic, strong) IBInspectable UIImage *listCellBackgroundImage;

/**
 *  下啦列表单元格,选中项的背景色(图片平铺)
 */
@property (nonatomic, strong) IBInspectable UIImage *listCellBackgroundImageSelected;

/**
 *  下啦列表单元格高度
 */
@property (nonatomic, assign) IBInspectable CGFloat listCellHeight;

/**
 *  更新子视图
 */
- (void)updateSubViews;

/**
 *  设置下啦列表背景色
 *
 *  @param color 背景色
 */
- (void)setListBackColor:(UIColor *)color;



@end
