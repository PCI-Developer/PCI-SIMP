//
//  PopMenu.h
//  PopMenu
//
//  Created by 吴非凡 on 15/10/27.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  弹出菜单
 */
@interface PopMenu : NSObject

/**
 *  构造器
 *
 *  @param titleArray     显示的标题
 *  @param imageArray     显示的图片
 *  @param touchPoint     以该点为参考点弹出
 *  @param view           touchPoint的view
 *  @param clickItemBlock 点击某项的回调block
 */
+ (void)popMenuWithTitles:(NSArray *)titleArray images:(NSArray *)imageArray touchPoint:(CGPoint )touchPoint onView:(UIView *)view clickItemBlock:(void (^)(NSInteger index))clickItemBlock;

@end
