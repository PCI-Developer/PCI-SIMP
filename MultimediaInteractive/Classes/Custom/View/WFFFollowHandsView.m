//
//  WFFFollowHandsView.m
//  Custom
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "WFFFollowHandsView.h"
#import "DeviceCollectionViewCell.h"
#import "DeviceForUser.h"

@interface WFFFollowHandsView()<UIGestureRecognizerDelegate>
{
    CGPoint defaultPoint;
    CGPoint beginPoint;
    UIPanGestureRecognizer *panGR;
    UITapGestureRecognizer *tapGR;
    UILongPressGestureRecognizer *longPressGR;
}

@end

@implementation WFFFollowHandsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRAction:)];
        tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGRAction:)];
        longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGRAction:)];
        longPressGR.delegate = self;
        self.alphaForMove = 0.3;
        self.canMove = YES;
        self.canClick = NO;
        self.canLongPress = NO;
    }
    return self;
}

- (UIPanGestureRecognizer *)panGR
{
    return panGR;
}

- (void)updateUIByState:(BOOL)isMoving
{
    if (isMoving) {
//        self.layer.borderColor = [UIColor blackColor].CGColor;
//        self.layer.borderWidth = 2;
        self.alpha = self.alphaForMove;
    } else {
//        self.layer.borderColor = [UIColor clearColor].CGColor;
//        self.layer.borderWidth = 0;
        self.alpha = 1;
    }
}

- (void)setCanClick:(BOOL)canClick
{
    if (_canClick != canClick) {
        _canClick = canClick;
        if (canClick) {
            [self addGestureRecognizer:tapGR];
        } else {
            [self removeGestureRecognizer:tapGR];
        }
    }
}

- (void)setCanMove:(BOOL)canMove
{
    if (_canMove != canMove) {
        _canMove = canMove;
        if (canMove) {
            [self addGestureRecognizer:panGR];
        } else {
            [self removeGestureRecognizer:panGR];
        }
    }
}

- (void)setCanLongPress:(BOOL)canLongPress
{
    if (_canLongPress != canLongPress) {
        _canLongPress = canLongPress;
        if (canLongPress) {
            [self addGestureRecognizer:longPressGR];
        } else {
            [self removeGestureRecognizer:longPressGR];
        }
    }
}

- (void)tapGRAction:(UITapGestureRecognizer *)sender
{
    if ([_delegate respondsToSelector:@selector(clickFollowHandsView:)]) {
        [_delegate clickFollowHandsView:self];
    }
}

- (void)longPressGRAction:(UILongPressGestureRecognizer *)sender
{
    if ([_delegate respondsToSelector:@selector(longPressFollowHandsView:gr:)]) {
        [_delegate longPressFollowHandsView:self gr:sender];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == longPressGR && otherGestureRecognizer == tapGR) {
        return NO;
    }
    return YES;
}

- (void)panGRAction:(UIPanGestureRecognizer *)sender
{

    UIView *superView = self.superview;
    CGPoint point = [sender locationInView:superView];
    CGFloat dx, dy;
    dx = point.x - beginPoint.x;
    dy = point.y - beginPoint.y;
    CGPoint newCenterPoint = CGPointMake(defaultPoint.x + dx, defaultPoint.y + dy);
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            defaultPoint = sender.view.center;
            beginPoint = point;
                [self updateUIByState:YES];
            
            if ([_delegate respondsToSelector:@selector(followHandsView:beginMoveWithHandsPointInSuperView:)]) {
                [_delegate followHandsView:self beginMoveWithHandsPointInSuperView:point];
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
                sender.view.center = defaultPoint;
                [self updateUIByState:NO];
            
            if ([_delegate respondsToSelector:@selector(followHandsView:cancelMoveWithHandsPointInSuperView:)]) {
                [_delegate followHandsView:self cancelMoveWithHandsPointInSuperView:point];
            }
            break;
            
        case UIGestureRecognizerStateChanged:
                sender.view.center = newCenterPoint;
                [self updateUIByState:YES];
            
            if ([_delegate respondsToSelector:@selector(followHandsView:movingWithHandsPointInSuperView:)]) {
                [_delegate followHandsView:self movingWithHandsPointInSuperView:point];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
                sender.view.center = newCenterPoint;
                [self updateUIByState:NO];
            if ([_delegate respondsToSelector:@selector(followHandsView:endMoveWithHandsPointInSuperView:)]) {
                [_delegate followHandsView:self endMoveWithHandsPointInSuperView:point];
            }
            break;
            
        default:
            break;
    }
}

- (void)beginMoveByGR:(UIGestureRecognizer *)gr
{
    UIView *superView = self.superview;
    CGPoint point = [gr locationInView:superView];
//    CGFloat dx, dy;
//    dx = point.x - beginPoint.x;
//    dy = point.y - beginPoint.y;
//    CGPoint newCenterPoint = CGPointMake(defaultPoint.x + dx, defaultPoint.y + dy);
    
    defaultPoint = self.center;
    beginPoint = point;
    [self updateUIByState:YES];
    if ([_delegate respondsToSelector:@selector(followHandsView:beginMoveWithHandsPointInSuperView:)]) {
        [_delegate followHandsView:self beginMoveWithHandsPointInSuperView:point];
    }
}

- (void)moveByGR:(UIGestureRecognizer *)gr
{
    UIView *superView = self.superview;
    CGPoint point = [gr locationInView:superView];
    CGFloat dx, dy;
    dx = point.x - beginPoint.x;
    dy = point.y - beginPoint.y;
    CGPoint newCenterPoint = CGPointMake(defaultPoint.x + dx, defaultPoint.y + dy);
    
    self.center = newCenterPoint;
    [self updateUIByState:YES];
    if ([_delegate respondsToSelector:@selector(followHandsView:movingWithHandsPointInSuperView:)]) {
        [_delegate followHandsView:self movingWithHandsPointInSuperView:point];
    }
}

- (void)endMoveByGR:(UIGestureRecognizer *)gr
{
    UIView *superView = self.superview;
    CGPoint point = [gr locationInView:superView];
    CGFloat dx, dy;
    dx = point.x - beginPoint.x;
    dy = point.y - beginPoint.y;
    CGPoint newCenterPoint = CGPointMake(defaultPoint.x + dx, defaultPoint.y + dy);
    
    self.center = newCenterPoint;
    [self updateUIByState:NO];
    if ([_delegate respondsToSelector:@selector(followHandsView:endMoveWithHandsPointInSuperView:)]) {
        [_delegate followHandsView:self endMoveWithHandsPointInSuperView:point];
    }
}


#pragma mark 出现可移动view[根据cell的imageView的位置出现. 根据device的id设置tag]
+ (WFFFollowHandsView *)followHandsViewWithWidth:(CGFloat)width height:(CGFloat)height deviceCell:(DeviceCollectionViewCell *)cell device:(DeviceForUser *)device onView:(UIView *)view
{
    CGRect pressRect = [cell convertRect:cell.contentView.frame toView:view];
    WFFFollowHandsView *followHandsView = [[WFFFollowHandsView alloc] initWithFrame:CGRectMake(pressRect.origin.x + (pressRect.size.width - width) / 2, pressRect.origin.y + (pressRect.size.height - height) / 2, width, height)];
    
    
    // 选中状态
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"state_%d",1]]];
    imageView.frame = followHandsView.bounds;
    imageView.backgroundColor = [UIColor clearColor];
    [followHandsView addSubview:imageView];
    
    // 设备图标 (一个个移动,需要加载图片动画)
    UIImageView *deviceImage = [[UIImageView alloc] initWithFrame:followHandsView.bounds];
    deviceImage.image = [UIImage imageNamed:[device imageNameByStatusRunAnimationOnImageView:deviceImage]];
    [followHandsView addSubview:deviceImage];
    
    followHandsView.tag = device.AutoID;
    [view addSubview:followHandsView];
    return followHandsView;
}

+ (WFFFollowHandsView *)followHandsViewByRandomPositionWithWidth:(CGFloat)width height:(CGFloat)height device:(DeviceForUser *)device onView:(UIView *)view
{
    int ori_X = arc4random() % (int)(view.frame.size.width - kFollowHandsViewOfDeviceWidth);
    int ori_Y = arc4random() % (int)(view.frame.size.height - kFollowHandsViewOfDeviceHeight);
    WFFFollowHandsView *followHandsView = [[WFFFollowHandsView alloc] initWithFrame:CGRectMake(ori_X, ori_Y, width, height)];
    // 选中状态
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"state_%d",1]]];
    imageView.frame = followHandsView.bounds;
    imageView.backgroundColor = [UIColor clearColor];
    [followHandsView addSubview:imageView];
    
    // 设备图标
    
    UIImageView *deviceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[device imageNameByStatusRunAnimationOnImageView:nil]]];
    deviceImage.frame = followHandsView.bounds;
    [followHandsView addSubview:deviceImage];
    
    followHandsView.tag = device.AutoID;
    [view addSubview:followHandsView];
    return followHandsView;
}

+ (WFFFollowHandsView *)followHandsViewByOrderWithWidth:(CGFloat)width height:(CGFloat)height device:(DeviceForUser *)device onView:(UIView *)view num:(NSInteger)num
{
    NSInteger rowMargin = 30;
    NSInteger colMargin = 20;
    
    // 一共可放置几列
    NSInteger colNum = view.frame.size.width / (width + colMargin);
    // 一共可放置几行
    NSInteger rowNum = (view.frame.size.height - 100) / (height + rowMargin); // 100是操作界面的高度
    // 当前行列
    NSInteger currentRow = num / colNum;
    NSInteger currentCol = num % colNum;
    
    if (currentRow >= rowNum) { // 超出屏幕 ,随机位置
        return [self followHandsViewByRandomPositionWithWidth:width height:height device:device onView:view];
    }
    
    int ori_X = currentCol * (width + colMargin);
    int ori_Y = 100 + currentRow * (height + rowMargin);
    WFFFollowHandsView *followHandsView = [[WFFFollowHandsView alloc] initWithFrame:CGRectMake(ori_X, ori_Y, width, height)];
    // 选中状态
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"state_%d",1]]];
    imageView.frame = followHandsView.bounds;
    imageView.backgroundColor = [UIColor clearColor];
    [followHandsView addSubview:imageView];
    
    // 设备图标
    
    UIImageView *deviceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[device imageNameByStatusRunAnimationOnImageView:nil]]];
    deviceImage.frame = followHandsView.bounds;
    [followHandsView addSubview:deviceImage];
    
    followHandsView.tag = device.AutoID;
    [view addSubview:followHandsView];
    return followHandsView;
    
}

- (void)showBorderColor:(BOOL)isShow color:(UIColor *)color
{
    if (isShow) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = color.CGColor;
    } else {
        self.layer.borderWidth = 0;
    }
}
@end
