//
//  OPManager.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/25.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

// 打开设备
#define kDeviceOpen(device, block) [[OPManager shareOPManager] deviceOpenWithDevice:device resultBlock:block]
// 关闭设备
#define kDeviceClose(device, block) [[OPManager shareOPManager] deviceCloseWithDevice:device resultBlock:block]
// 音频文件操控
#define kControlMusicFile(tag, device, block) [[OPManager shareOPManager] deviceControlMusicFileWithTag:tag file:device resultBlock:block]
// 音频设备连接
#define kConnMusicFile(device, other, block) [[OPManager shareOPManager] deviceConnMusicFileWithFile:device otherDevice:other resultBlock:block]

// 设置设备值
#define kDeviceSetValue(device, value, block) [[OPManager shareOPManager] deviceSetValueWithDevice:device deviceValue:value resultBlock:block]
// 连接设备
#define kDeviceConn(device, other, block) [[OPManager shareOPManager] deviceConnWithDevice:device otherDevice:other resultBlock:block]
// 设备云台控制
#define kDeviceStartPTZ(device, orientation, block) [[OPManager shareOPManager] deviceStartPTZWithOrientation:orientation deviceForUser:device resultBlock:block]
// 设备云台控制停止
#define kDeviceStopPTZ(device, block) [[OPManager shareOPManager] deviceStopPTZWtihDevice:device resultBlock:block]


// 批量打开设备
#define kDeviceBatchOpen(devices, block) [[OPManager shareOPManager] deviceBatchOpenWithDevices:devices resultBlock:block]
// 批量关闭设备
#define kDeviceBatchClose(devices, block) [[OPManager shareOPManager] deviceBatchCloseWithDevices:devices resultBlock:block]
// 批量设置设备值
#define kDeviceBatchSetValue(devices, value, block) [[OPManager shareOPManager] deviceBatchSetValueWithDevices:devices deviceValue:value resultBlock:block]
// 批量连接设备
#define kDeviceBatchConn(devices, others, block) [[OPManager shareOPManager] deviceBatchConnWithDevice:devices otherDevice:others resultBlock:block]

// 摄像头跟随
#define kCameraFollow(device, value, block) [[OPManager shareOPManager] deviceConfigCameraFollowWithDevice:device deviceValue:value resultBlock:block];

@interface OPManager : NSObject

kSingleTon_H(OPManager)

typedef void (^ControlResultWithDeviceBlock)(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser);
typedef void (^BatchControlResultWithDeviceBlock)(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices);

#pragma mark - 单个设备操作
- (void)deviceOpenWithDevice:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock;

- (void)deviceCloseWithDevice:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock;

- (void)deviceSetValueWithDevice:(DeviceForUser *)device deviceValue:(NSString *)value resultBlock:(ControlResultWithDeviceBlock)resultBlock;

- (void)deviceConnWithDevice:(DeviceForUser *)device otherDevice:(DeviceForUser *)otherDevice resultBlock:(ControlResultWithDeviceBlock)resultBlock;

- (void)deviceStartPTZWithOrientation:(NSInteger)orientation deviceForUser:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock;

- (void)deviceStopPTZWtihDevice:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock;
// 电视频道
- (void)deviceChangeChannelWtihDevice:(DeviceForUser *)device channel:(NSString *)channel  resultBlock:(ControlResultWithDeviceBlock)resultBlock;
// 配置摄像头跟随
- (void)deviceConfigCameraFollowWithDevice:(DeviceForUser *)device deviceValue:(NSString *)value resultBlock:(ControlResultWithDeviceBlock)resultBlock;
// 音频文件
- (void)deviceConnMusicFileWithFile:(DeviceForUser *)device otherDevice:(DeviceForUser *)otherDevice resultBlock:(ControlResultWithDeviceBlock)resultBlock;
- (void)deviceControlMusicFileWithTag:(NSInteger)tag file:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock;

#pragma mark - 批量操作
- (void)deviceBatchOpenWithDevices:(NSArray *)deviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock;
- (void)deviceBatchCloseWithDevices:(NSArray *)deviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock;
- (void)deviceBatchSetValueWithDevices:(NSArray *)deviceArray deviceValue:(NSString *)value resultBlock:(BatchControlResultWithDeviceBlock)resultBlock;

- (void)deviceBatchConnWithDevice:(NSArray *)deviceArray otherDevice:(NSArray *)otherDeviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock;

// 频道
- (void)deviceBatchChangeChannelWithDevice:(NSArray *)deviceArray  channel:(NSString *)channel otherDevice:(NSArray *)otherDeviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock;



@end
