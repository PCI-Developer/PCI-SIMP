//
//  UIView+Animation.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/12.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void)setBackgroundColorFromHexColor:(NSString *)backgroundColorFromHexColor
{
    self.backgroundColor = kHexColor(backgroundColorFromHexColor);
}

- (NSString *)backgroundColorFromHexColor
{
    return nil;
}

- (void)setBackgroundColorFromUIImage:(UIImage *)backgroundColorFromUIImage
{
    self.backgroundColor = [UIColor colorWithPatternImage:backgroundColorFromUIImage];
}

- (UIImage *)backgroundColorFromUIImage
{
    return nil;
}



#pragma mark - 令指定view颤抖
- (void)shake
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.values = @[@(0), @(-M_PI / 15), @(0), @(M_PI / 15), @(0)];
    animation.duration = 0.2;
    animation.repeatCount = 2;
    [self.layer addAnimation:animation forKey:@""];
}

- (void)shakeWithDuration:(CGFloat)duration
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.values = @[@(0), @(-M_PI / 15), @(0), @(M_PI / 15), @(0)];
    animation.duration = duration;
    animation.repeatCount = 2;
    [self.layer addAnimation:animation forKey:@""];
}

- (void)addTransitionWithType:(NSString *)type subType:(NSString *)subType duration:(CGFloat)duration key:(NSString *)key
{
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.type = type;
    animation.subtype = subType;
    [self.layer addAnimation:animation forKey:key];
}

- (void)removeAnimationForKey:(NSString *)key
{
    [self.layer removeAnimationForKey:key];
}


- (void)startRotation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VAL;
    
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopRotation
{
    if ([self.layer animationForKey:@"rotationAnimation"]) {
        [self.layer removeAnimationForKey:@"rotationAnimation"];
    }
}

// 是否带转场动画的隐藏
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setHidden:hidden animated:animated completionHandle:nil];
}

// 是否带转场动画的隐藏
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completionHandle:(void (^)())completionHandle
{
    NSTimeInterval timeInterval = 0;
    if (animated) {
        NSString *subType = hidden ? kCATransitionFromLeft : kCATransitionFromRight;
        timeInterval = 0.25;
        [self addTransitionWithType:kRightViewTransitionType subType:subType duration:0.25 key:@"transition"];
    }
    if (!hidden) { // 要显示
        [self.superview bringSubviewToFront:self];
    }
    
    [super setValue:@(hidden) forKey:@"hidden"];
    
    if (completionHandle) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionHandle();
        });
    }
    
}

- (void)addSubview:(UIView *)view animated:(BOOL)animated
{
    [self addSubview:view animated:animated completionHandle:nil];
}

- (void)removeFromSuperviewWithAnimated:(BOOL)animated
{
    [self removeFromSuperviewWithAnimated:animated completionHandle:nil];
}

- (void)addSubview:(UIView *)view animated:(BOOL)animated completionHandle:(void (^)())completionHandle
{
    if (!view) {
        return;
    }
    NSTimeInterval timeInterval = 0;
    if (animated) {
        timeInterval = 0.25;
        [self addTransitionWithType:kRightViewTransitionType subType:kCATransitionFromRight duration:0.25 key:@"transition"];
    }
    [self removeFromSuperview];
    if (completionHandle) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionHandle();
        });
    }
}

- (void)removeFromSuperviewWithAnimated:(BOOL)animated completionHandle:(void (^)())completionHandle
{
    NSTimeInterval timeInterval = 0;
    if (animated) {
        timeInterval = 0.25;
        [self addTransitionWithType:kRightViewTransitionType subType:kCATransitionFromLeft duration:0.25 key:@"transition"];
    }
    [self removeFromSuperview];
    if (completionHandle) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionHandle();
        });
    }
}
@end
