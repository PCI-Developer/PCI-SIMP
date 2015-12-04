//
//  WFFCircularSlider.m
//  Block
//
//  Created by 吴非凡 on 15/12/1.
//  Copyright © 2015年 ROBERA GELETA. All rights reserved.
//

#import "WFFCircularSlider.h"

#define kStartRadian (M_PI * 2.0f / 3.0f) // 音量初始弧度 X+为基础

#define kRadianRange (M_PI * 2.0f - M_PI * 2.0f / 3.0f)

#define kThumbImageSize 30

#define kThumbMargin 0 // 按钮和边界的距离

@interface WFFCircularSlider ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *tintImageView;

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, strong) UIView *thumbBackgroundView;

@end

@implementation WFFCircularSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.backgroundColor = [UIColor blackColor];
    [self addSubview:_backgroundImageView];
    
    self.tintImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _tintImageView.backgroundColor = [UIColor cyanColor];
    [self addSubview:_tintImageView];
    
    
    self.value = 0;
    
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(grAction:)]];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grAction:)]];
//    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(grAction:)]];
    
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self.layer.masksToBounds = YES;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (_backgroundImage != backgroundImage) {
        _backgroundImage = nil;
        _backgroundImage = backgroundImage;
        _backgroundImageView.image = backgroundImage;
        if (_backgroundImage) {
            _backgroundImageView.backgroundColor = [UIColor clearColor];
        }
    }
}


- (void)setTintImage:(UIImage *)tintImage
{
    if (_tintImage != tintImage) {
        _tintImage = nil;
        _tintImage = tintImage;
        _tintImageView.image = tintImage;
        if (_tintImage) {
            _tintImageView.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    if (_thumbImage != thumbImage) {
        _thumbImage = nil;
        _thumbImage = thumbImage;
        if (!_thumbImageView) {
            // thumbImageView的初始位置为X+. 后面根据value来旋转
            CGRect rectForThumbImageView = CGRectMake(CGRectGetMaxX(self.bounds) - thumbImage.size.width- kThumbMargin, CGRectGetMidY(self.bounds) - thumbImage.size.height / 2, thumbImage.size.width, thumbImage.size.height);
            self.thumbImageView = [[UIImageView alloc] initWithFrame:rectForThumbImageView];
            
            self.thumbBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _thumbBackgroundView.backgroundColor = [UIColor clearColor];
            [_thumbBackgroundView addSubview:_thumbImageView];
            [self addSubview:_thumbBackgroundView];
            
        }
        _thumbImageView.image = _thumbImage;
        [self rotationThumbImageViewByCurrentValue];
    }
}

- (void)setValue:(CGFloat)value
{
    if (_value != value) {
        _value = value;
        
        [self rotationThumbImageViewByCurrentValue];
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [self clip];
}

- (void)rotationThumbImageViewByCurrentValue
{
    if (!_thumbImageView) {
        return;
    }
    CGFloat radian = _value / 1.0f * kRadianRange + kStartRadian;
    _thumbBackgroundView.transform = CGAffineTransformMakeRotation(radian);
    return;
}

#pragma mark - 裁剪
- (void)clip
{
    CGFloat dRadian = _value / 1.0f * kRadianRange;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = [self rotationAroundCirclePoint:(CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)} radius:CGRectGetWidth(self.bounds) / 2 radian:kStartRadian];
    [path moveToPoint:startPoint];
    [path addArcWithCenter:(CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)} radius:CGRectGetWidth(self.bounds) / 2 startAngle:kStartRadian endAngle:dRadian + kStartRadian clockwise:YES];
    [path addLineToPoint:(CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)}];
    [path closePath];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    self.tintImageView.layer.mask = shapeLayer;
    
    
}

#pragma mark - 手势
- (void)grAction:(UIGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self];
    CGFloat radian = [self point2RadianWithLoc:touchPoint view:self];
    
    // 在0 - kStartRadian的范围内,
    if (radian < kStartRadian) {
        radian += M_PI * 2;
    }
    
    CGFloat value = (radian - kStartRadian) / kRadianRange;
    
    
    
    // 不允许超出范围,即大于1 -- 对于这个起始和终止,value > 1代表的就是起始点和终止点之间的位置.
    if (value > 1 && [sender isKindOfClass:[UIPanGestureRecognizer class]]) { // 如果是直接点击的话, 也进行赋值
        // 不对_value赋值.value的setter中,会更新界面显示
        // 假如这里令value = 1时,当从起始点往终止点方向一动就会突兀的跳至终止点.
        // 同理,假如令value = 0时,当从终止点往起始点方向一动就会突兀的跳至起始点
    } else {
        self.value = value > 1 ? 1 : value;
    }
    
    
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSliderLeaveFocusNotification object:self];
        // 找不到可用的sendAction, touchCancel会与系统重复
    }
}

#pragma mark - 数学公式
//  X+为基础,换算loc的弧度值
- (CGFloat)point2RadianWithLoc:(CGPoint)loc view:(UIView *)view
{
    CGPoint c = CGPointMake(CGRectGetMidX(view.bounds),
                            CGRectGetMidY(view.bounds));
    
    CGFloat radianByX = atan2(loc.y - c.y, loc.x - c.x);
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
