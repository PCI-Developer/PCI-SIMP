//
//  DeviceForUser.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/15.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceForUser : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger AutoID;

@property (nonatomic, copy) NSString *UEQP_ID;

@property (nonatomic, copy) NSString *UEQP_Name;

@property (nonatomic, copy) NSString *UEQP_Type;
//
//@property (nonatomic, copy) NSString *EQPID_Ctrl;
//
//@property (nonatomic, copy) NSString *EQPID_Sound;
//
//@property (nonatomic, copy) NSString *EQPID_Video;

@property (nonatomic, copy) NSString *AreaID;

//@property (nonatomic, copy) NSString *Remark;

@property (nonatomic, copy) NSString *imageName;

// 开关状态 - (操作成功后反馈的结果)
@property (nonatomic, assign) DeviceOCState deviceOCState;

// 设备值
@property (nonatomic, copy) NSString *value;

// 频道(电视专属)
@property (nonatomic, copy) NSString *channel;

// 状态 (包括连接和开关状态)
@property (nonatomic, assign) DeviceConnectState deviceConnectState;

// 连接的设备(只有输出源该属性才有值[一个输出源只能绑定一个输入源])
@property (nonatomic, strong) DeviceForUser *connectedDevice;

// 配置的项 [键:OC VALUE CONN CHANNEL] -- 当前配置项.任何经过OPManager的操作.一旦操作成功,都会被记录在currentConfigs中.
@property (nonatomic, strong) NSMutableDictionary *currentConfigs;

// 配置的项 [键:OC VALUE CONN] -- 本地配置项.根据选择不同的配置.该属性具有不同值.
@property (nonatomic, strong) NSMutableDictionary *localConfig;

// 操控所需权限
@property (nonatomic, assign) NSInteger needLevel;

// 是否开启跟随 (摄像头才有该字段)
@property (nonatomic, assign) BOOL needFollow;

// 跟随的设备ID (暂定只有麦克有该值,UEQP_ID对应设备必须是摄像头,其他则认为无效)
@property (nonatomic, copy) NSString *followUEQP_ID;

/**
 *  设置当前开关状态及连接状态所对应的图片
 *  连接打开时,执行或停止动画
 *
 *  @param imageView 要设置的imageView
 *
 *  @return 获取图片名字
 */
- (NSString *)setImageWithDeviceStatusAndRunAnimationOnImageView:(UIImageView *)imageView;

@end

