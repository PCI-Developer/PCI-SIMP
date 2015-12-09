//
//  DeviceForUser.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/15.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "DeviceForUser.h"

@implementation DeviceForUser

- (NSString *)imageName
{
    return kDeviceTypeInfo(self.UEQP_Type)[@"imageName"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"设备类型:%@ 名称:%@", kDeviceTypeInfo(self.UEQP_Type)[@"name"], self.UEQP_Name];
}

- (NSString *)imageNameByStatusRunAnimationOnImageView:(UIImageView *)imageView
{
    NSString *imageName = nil;
    BOOL needAnimation = NO;
    if (self.deviceConnectState == DeviceStateConnect) { // 返回该值,说明无法获取开关状态,开关状态由DeviceOCState判断
        if (self.deviceOCState == DeviceClose) {
            imageName = [NSString stringWithFormat:@"%@_close", self.imageName];
        } else if (self.deviceOCState == DeviceOpen) {
            needAnimation = YES;
            imageName = [NSString stringWithFormat:@"%@_open", self.imageName];
        } else {
            imageName = [NSString stringWithFormat:@"%@_ocUnknow", self.imageName];
        }
    } else if (self.deviceConnectState == DeviceStateUnknow) { // 默认状态
        imageName = [NSString stringWithFormat:@"%@_unKnow", self.imageName];
    } else if (self.deviceConnectState == DeviceStateDisConnect){ // 未连接
        imageName = [NSString stringWithFormat:@"%@_disConn", self.imageName];
    } /*else if (self.deviceConnectState == DeviceStateOpen){ // 打开
        needAnimation = YES;
        imageName = [NSString stringWithFormat:@"%@_open", self.imageName];
    } else if (self.deviceConnectState == DeviceStateClose){ // 关闭
        imageName = [NSString stringWithFormat:@"%@_close", self.imageName];
    }*/
    
    if (imageView) {
        if (needAnimation) { // 需要动画
            if ([imageView.animationImages count] > 0 && !imageView.isAnimating) { // 之前配过
                [imageView startAnimating];
            } else {
                imageView.animationDuration = 0.5;
                imageView.animationRepeatCount = HUGE_VAL;
                imageView.animationImages = @[[UIImage imageNamed:[NSString stringWithFormat:@"%@_open", self.imageName]], [UIImage imageNamed:[NSString stringWithFormat:@"%@_open1", self.imageName]]];
                [imageView startAnimating];
            }
        } else {// 不需要动画
            if ([imageView.animationImages count] > 0 && imageView.isAnimating) {
                [imageView stopAnimating];
                imageView.animationImages = nil;
            }
        }
    }
    
//    kLog(@"%@", imageName);
    return imageName;
}

#pragma mark - LazyLoading
- (NSMutableDictionary *)currentConfigs
{
    if (!_currentConfigs) {
        _currentConfigs = [NSMutableDictionary dictionary];
    }
    return _currentConfigs;
}

#pragma mark - 归档 解档
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        unsigned int ivarsCount;
        Ivar *ivars = class_copyIvarList([self class], &ivarsCount);
        for (int i = 0; i < ivarsCount; i++) {
            Ivar ivar = ivars[i];
            NSString *name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            
            [self setValue:[aDecoder decodeObjectForKey:name] forKey:name];
            
        }
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int ivarsCount;
    Ivar *ivars = class_copyIvarList([self class], &ivarsCount);
    for (int i = 0; i < ivarsCount; i++) {
        Ivar ivar = ivars[i];
        NSString *name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        
        [aCoder encodeObject:[self valueForKey:name] forKey:name];
    }
}


@end
