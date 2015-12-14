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
    if (animated) {
        NSString *subType = hidden ? kCATransitionFromLeft : kCATransitionFromRight;
        [self addTransitionWithType:kRightViewTransitionType subType:subType duration:0.25 key:@"transition"];
    }
    if (!hidden) { // 要显示
        [self.superview bringSubviewToFront:self];
    }
    [super setValue:@(hidden) forKey:@"hidden"];
}

// 是否带转场动画的隐藏
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completionHandle:(void (^)())completionHandle
{
    if (animated) {
        NSString *subType = hidden ? kCATransitionFromLeft : kCATransitionFromRight;
        [self addTransitionWithType:kRightViewTransitionType subType:subType duration:0.25 key:@"transition"];
    }
    if (!hidden) { // 要显示
        [self.superview bringSubviewToFront:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandle();
    });
    [super setValue:@(hidden) forKey:@"hidden"];
}

@end
