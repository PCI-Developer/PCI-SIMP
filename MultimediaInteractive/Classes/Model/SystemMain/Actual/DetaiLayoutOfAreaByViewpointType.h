//
//  DetaiLayoutOfAreaByViewpointType.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/12.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  设备的布局模型
 */
@interface DetaiLayoutOfAreaByViewpointType : NSObject

/**
 *  区域
 */
@property (nonatomic, copy) NSString *areaID;

/**
 *  视角
 */
@property (nonatomic, assign) ViewPointType viewpointType;

/*
 * 获取设备后,自动生成.
 */
@property (nonatomic, copy) NSString *deviceID;

/**
 *  起始点X
 */
@property (nonatomic, assign) CGFloat origin_X;

/**
 *  起始点Y
 */
@property (nonatomic, assign) CGFloat origin_Y;

/**
 *  宽度
 */
@property (nonatomic, assign) CGFloat size_Width;

/**
 *  高度
 */
@property (nonatomic, assign) CGFloat size_Height;

/**
 *  对应的设备
 */
@property (nonatomic, strong) DeviceForUser *device;

@end
