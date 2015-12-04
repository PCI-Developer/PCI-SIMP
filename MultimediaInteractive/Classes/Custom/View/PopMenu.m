//
//  PopMenu.m
//  PopMenu
//
//  Created by 吴非凡 on 15/10/27.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "PopMenu.h"
#import "UIView+Animation.h"
#define kRadius 100 // 半径

#define kPopViewSize 30 // 每个弹出view的大小

//#define kScreenWidth [UIScreen mainScreen].bounds].size.width
//
//#define kScreenHeight [UIScreen mainScreen].bounds].size.height

#define kAngle2Radian(angle) (angle / 180.0f * M_PI) // 角度 -> 弧度

#define kRadin2Angle(radian) (radian / M_PI * 180.0f) // 弧度 -> 角度

@interface PopMenu ()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation PopMenu

static void (^clickItem)(NSInteger index);

+ (void)popMenuWithTitles:(NSArray *)titleArray images:(NSArray *)imageArray touchPoint:(CGPoint )touchPoint onView:(UIView *)view clickItemBlock:(void (^)(NSInteger index))clickItemBlock
{
    
    
    clickItem = clickItemBlock;
    
    UIView *mainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewTapGRAction:)]];
    mainView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    [[UIApplication sharedApplication].keyWindow addSubview:mainView];
    
    // 角度从y轴正方向为0度角开始顺时针计算
    CGFloat angleRange = 0; // 根据触摸点位置,计算出popview的分布角度(最大360 ,最小90)
    NSMutableString *quadrantCanShow = [NSMutableString stringWithFormat:@""];// popview允许存在的象限
    
    // 获取触摸点坐标
    CGPoint point = [view convertPoint:touchPoint toView:mainView];
    if (point.x + kRadius + kPopViewSize / 2 <= CGRectGetMaxX(mainView.bounds)
        && point.y - kRadius - kPopViewSize >= CGRectGetMinY(mainView.bounds)) {
        angleRange += 90;
        [quadrantCanShow appendFormat:@"%d,", 1];
    }
    
    if (point.x + kRadius + kPopViewSize / 2 <= CGRectGetMaxX(mainView.bounds)
        && point.y + kRadius + kPopViewSize <= CGRectGetMaxY(mainView.bounds)) {
        angleRange += 90;
        [quadrantCanShow appendFormat:@"%d,", 2];
    }
    
    if (point.x - kRadius - kPopViewSize / 2 >= CGRectGetMinX(mainView.bounds)
        && point.y + kRadius + kPopViewSize <= CGRectGetMaxY(mainView.bounds)) {
        angleRange += 90;
        [quadrantCanShow appendFormat:@"%d,", 3];
    }
    
    if (point.x - kRadius - kPopViewSize / 2 >= CGRectGetMinX(mainView.bounds)
        && point.y - kRadius - kPopViewSize >= CGRectGetMinY(mainView.bounds)) {
        angleRange += 90;
        [quadrantCanShow appendFormat:@"%d,", 4];
    }
    
    // 旋转前的坐标(X轴正方向为0)
    CGFloat beginAngle = 0;
    
    // 必须倒序判断,因为有1.4象限的可能.倒序先判断4象限
    if ([quadrantCanShow containsString:@"1"] && [quadrantCanShow containsString:@"4"]) {
        beginAngle = 0;
    } else if ([quadrantCanShow containsString:@"4"]) {
        beginAngle = 90;
    } else if ([quadrantCanShow containsString:@"3"]) {
        beginAngle = 180;
    } else if ([quadrantCanShow containsString:@"2"]) {
        beginAngle = 270;
    } else if ([quadrantCanShow containsString:@"1"]) {
        beginAngle = 0;
    }
    
    angleRange = angleRange > 180 ? 180 : angleRange; // 设置最大角度区域等于180
    
    CGFloat dAngle; // 每个view间隔的角度
    dAngle = angleRange / (titleArray.count + 1); // 多加两个区域置于头尾.
//    if (angleRange == 360) {
//        dAngle = angleRange / titleArray.count; // 360度的时候, 要多一个区域,否则头尾重合
//    } else {
//       dAngle = angleRange / (titleArray.count - 1); // 数组-1个区域
//    }
    
    
//    CGRect fromRect = CGRectMake(point.x - kPopViewSize / 2, point.y - kPopViewSize / 2, kPopViewSize, kPopViewSize);
    
    int index = 0;
    for (int i = (int)titleArray.count - 1; i >= 0; i--) {
        CGFloat angleBeginFromX = beginAngle + dAngle * (i + 1); // 开始角度 - 以X轴正向逆时针方向计算
        CGPoint newPoint = [self rotationAroundCirclePoint:point radius:kRadius radian:kAngle2Radian(-angleBeginFromX)]; // 找出新的点
        CGRect viewRect = CGRectMake(newPoint.x - kPopViewSize / 2, newPoint.y - kPopViewSize / 2, kPopViewSize, kPopViewSize); // 根据新的点计算frame
        
        UIView *view = [[UIView alloc] initWithFrame:viewRect];

        view.layer.cornerRadius = kPopViewSize / 2;
        
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popViewTapGRAction:)]];
        
        // 透明
        view.alpha = 0;
        // 缩小一半
        view.transform = CGAffineTransformScale(view.transform, 0.5, 0.5);
        // 点击事件获取下标
        view.tag = 100 + i;
        
        [mainView addSubview:view];
        
        // 动画 - 延迟:有序出现
        [UIView animateWithDuration:0.3 delay:0.3 / titleArray.count * index++ options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            view.alpha = 1;
            view.transform = CGAffineTransformScale(view.transform, 3, 3);
            view.backgroundColor = [UIColor redColor];
        } completion:^(BOOL finished) {
        }];
        
    }
}


/*
 圆上的某点逆时针沿着圆的轨迹旋转radian度后的坐标
 */
+ (CGPoint)rotationAroundCirclePoint:(CGPoint)circlePoint radius:(CGFloat)radius radian:(CGFloat)radian
{
    CGFloat newX = circlePoint.x + radius * cos(radian);
    CGFloat newY = circlePoint.y + radius * sin(radian);
    return (CGPoint){newX, newY};
}

/*
 点击
 */
+ (void)mainViewTapGRAction:(UITapGestureRecognizer *)sender
{
    [sender.view removeFromSuperview];
}

+ (void)popViewTapGRAction:(UITapGestureRecognizer *)sender
{
    if (clickItem) {
        clickItem(sender.view.tag - 100);
    }
}

@end
