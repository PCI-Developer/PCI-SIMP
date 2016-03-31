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
#import "UIView+Addition.h"
@interface WFFFollowHandsView()<UIGestureRecognizerDelegate>
{
    CGPoint defaultPoint;
    CGPoint beginPoint;
    UIPanGestureRecognizer *panGR;
    UITapGestureRecognizer *tapGR;
    UILongPressGestureRecognizer *longPressGR;
    CALayer *indicatorForRotationLayer;
    CGFloat radianStartRotation;
    CGFloat radianBeforeRotation;
}

@property (nonatomic, assign) BOOL isRotation;

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
        self.isRotation = NO;
        self.rotationRadian = 0;
//        self.additionImage = [UIImage imageNamed:@"glow"];
//        self.additionScale = 0.5;
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
    if (_isRotation) {
        CGPoint point = [sender locationInView:sender.view];
        if (CGRectContainsPoint([self indicatorForRotationRect], point)) {
            [self endRotation];
        } else {
           self.rotationRadian += M_PI_2;
        }
    } else {
        if ([_delegate respondsToSelector:@selector(clickFollowHandsView:)]) {
            [_delegate clickFollowHandsView:self];
        }
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

CGFloat convertRadianToNormal(CGFloat radian)
{
    if (radian < 0) {
        radian += 2 * M_PI;
    }
    return radian;
}

- (void)panGRAction:(UIPanGestureRecognizer *)sender
{
    /*if (_isRotation) {
        CGFloat changedRadian;
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
                radianBeforeRotation = self.rotationRadian;
                radianStartRotation = [self point2RadianWithLoc:[sender locationInView:self] view:self];
                break;
                
            case UIGestureRecognizerStateCancelled:
                changedRadian = convertRadianToNormal([self point2RadianWithLoc:[sender locationInView:self] view:self] - radianStartRotation);
                radianStartRotation = 0;
                break;
                
            case UIGestureRecognizerStateChanged:
                changedRadian = convertRadianToNormal([self point2RadianWithLoc:[sender locationInView:self] view:self] - radianStartRotation);
                NSLog(@"起始角度 %f 变化角度%f", radianBeforeRotation / M_PI * 180, changedRadian / M_PI * 180);
                self.rotationRadian = radianBeforeRotation + changedRadian;
                break;
                
            case UIGestureRecognizerStateEnded:
                changedRadian = convertRadianToNormal([self point2RadianWithLoc:[sender locationInView:self] view:self] - radianStartRotation);
                radianStartRotation = 0;
                
//                self.rotationRadian = radianBeforeRotation + changedRadian;
//                NSLog(@"改变角度 %f, 最终角度 %f", changedRadian / M_PI * 180, self.rotationRadian / M_PI * 180);
                break;
                
            default:
                break;
        }
        
        
        
        
    } else {*/
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
    //}
    
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
    [device setImageWithDeviceStatusAndRunAnimationOnImageView:deviceImage];
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
    UIImageView *deviceImage = [[UIImageView alloc] initWithFrame:followHandsView.bounds];
    [device setImageWithDeviceStatusAndRunAnimationOnImageView:deviceImage];
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
    
    UIImageView *deviceImage = [[UIImageView alloc] initWithFrame:followHandsView.bounds];
    [device setImageWithDeviceStatusAndRunAnimationOnImageView:deviceImage];
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

#pragma mark - 旋转相关
- (void)setRotationRadian:(CGFloat)rotationRadian
{
    if (rotationRadian > 2 * M_PI) {
        self.rotationRadian = rotationRadian - (CGFloat)(((int)(rotationRadian / (M_PI * 2))) * M_PI * 2);
    } else {
        if (_rotationRadian != rotationRadian) {
            
            [self rotationWithRadian:rotationRadian];
            _rotationRadian = rotationRadian;
        }
    }
}

- (void)rotationWithRadian:(CGFloat)radian
{
//    self.layer.transform = CATransform3DMakeRotation(radian / M_PI * 180, 0, 0, 1);
    CALayer *topLayer = self.layer.sublayers.lastObject;
    topLayer.transform = CATransform3DRotate(CATransform3DIdentity, radian, 0, 0, 1);
}


- (void)setIsRotation:(BOOL)isRotation
{
    if (_isRotation != isRotation) {
        _isRotation = isRotation;
        self.canClick = _isRotation;
        if (isRotation) {
            if (!indicatorForRotationLayer) {
                indicatorForRotationLayer = [[CALayer alloc] init];
                indicatorForRotationLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"rotationButton"].CGImage);
                indicatorForRotationLayer.frame = [self indicatorForRotationRect];
                
            }
            [self.layer insertSublayer:indicatorForRotationLayer atIndex:0];
        } else {
            if (indicatorForRotationLayer) {
                [indicatorForRotationLayer removeFromSuperlayer];
            }
        }
    }
}

- (CGRect)indicatorForRotationRect
{
    // 45度角的点。
    CGPoint point = [self rotationAroundCirclePoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:self.bounds.size.width / 2 - 10 radian:- M_PI_4];
    return CGRectMake(point.x, point.y - (self.bounds.size.width - point.x), self.bounds.size.width - point.x, self.bounds.size.width - point.x);
}

- (void)beginRotation
{
    [self shakeWithDuration:0.25];
    self.isRotation = YES;
}

- (void)endRotation
{
    self.isRotation = NO;
}


#pragma mark - 数学公式
//  X+为基础,换算loc的弧度值
- (CGFloat)point2RadianWithLoc:(CGPoint)loc view:(UIView *)view
{
    CGPoint c = CGPointMake(CGRectGetMidX(view.bounds),
                            CGRectGetMidY(view.bounds));
    
    CGFloat radianByX = atan2(loc.y - c.y, loc.x - c.x);
    if (radianByX < 0) {
        radianByX += 2 * M_PI;
    }
    return radianByX;
}

/*
 圆上的某点逆时针沿着圆的轨迹旋转radian度后的坐标, X+为基础
 */
- (CGPoint)rotationAroundCirclePoint:(CGPoint)circlePoint radius:(CGFloat)radius radian:(CGFloat)radian
{
    CGFloat newX = circlePoint.x + radius * cos(radian);
    CGFloat newY = circlePoint.y + radius * sin(radian);
    return (CGPoint){newX, newY};
}


@end
