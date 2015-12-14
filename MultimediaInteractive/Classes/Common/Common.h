//
//  Common.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  获取所有区域,登陆时获取.不会重复向服务器请求
 */
#define kAllAreas ([[Common shareCommon] getAllAreas])
/**
 *  获取所有设备,登陆时获取,不会重复向服务器请求
 */
#define kAllDevices ([[Common shareCommon] getAllDevices])
/**
 *  获取指定设备类型的信息,登陆时获取,不会重复向服务器请求
 */
#define kDeviceTypeInfo(deviceType) ([[Common shareCommon] getInfoWithDeviceType:deviceType])
/**
 *  当前区域
 */
#define kCurrentArea ([[Common shareCommon] currentArea])
/**
 *  当前登陆用户
 */
#define kCurrentUser ([[Common shareCommon] currentUser])

/**
 *  当前区域流程
 */
#define kProcessByCurrentArea ([[Common shareCommon] processByCurrentArea])


/**
 *  当前区域实体设备
 */
#define kCurrentActualDeviceArray ([[Common shareCommon] getActualDevicesArray])
/**
 *  当前区域所有设备类型
 */
#define kAllTypeOfCurrentDevices ([[Common shareCommon] getAllDeviceTypes])

/**
 *  获取当前区域指定类型的所有设备
 */
#define kGetDevicesWithType(deviceType) ([[Common shareCommon] getDeviceWithType:deviceType])
/**
 *  当前区域指定视角的实景图
 */
#define kActualImage(viewpointType) ([[Common shareCommon] actualImageWithViewpointType:viewpointType])
/**
 *  设置当前区域指定视角的实景图
 */
#define kSetActualImage(viewpointType, image) [[Common shareCommon] setActualImage:image withViewpointType:viewpointType]
/**
 *  日志字典
 */
#define kLogDict ([[Common shareCommon] logDict])
/**
 *  将日志保存到内存中
 */
#define kCacheLog(log) [[Common shareCommon] cacheLogWithModel:log]


#define kCommonDevices [[Common shareCommon] commonDevices]
@class Area;
@class User;
@class DeviceForUser;
@class LogInfo;

@interface Common : NSObject

@property (nonatomic, assign) BOOL isDemo;

@property (nonatomic, assign) BOOL hasLogin;

#pragma mark - 单例
kSingleTon_H(Common)


- (User *)currentUser;
- (NSString *)userName;

- (Area *)currentArea;
- (NSString *)areaName;

#pragma mark - 获取当前区域所有设备类型
- (NSArray *)getAllDeviceTypes;

#pragma mark - 获取当前区域的输入源设备
- (NSDictionary *)getInDevicesDict;

#pragma mark - 获取当前区域的输出源设备
- (NSDictionary *)getOutDevicesDict;

#pragma mark - 获取当前区域的所有实体设备
- (NSArray *)getActualDevicesArray;

- (NSArray *)processByCurrentArea;

#pragma mark - 根据设备ID获取当前区域的实体设备
- (DeviceForUser *)getActualDeviceWithID:(NSInteger)deviceID;

#pragma mark - 根据设备ID获取设备(包含公共设备)
- (DeviceForUser *)getDeviceWithUEQP_ID:(NSString *)UEQP_ID;

#pragma mark - 根据设备类型获取该类型信息
- (NSDictionary *)getInfoWithDeviceType:(NSString *)deviceType;

#pragma mark - 获取当前区域指定类型的所有设备
- (NSArray *)getDeviceWithType:(NSString *)deviceType;

#pragma mark - 根据当前设备,获取该设备可连接的所有其他设备(设备为in类型,则返回空.默认只有out类型的设备,才显示可连接设备[因为in类型的设备,可连接多个out.界面不好显示连接的状态])
- (NSMutableArray *)getAllowConnectedDevicesWithModel:(DeviceForUser *)model;

#pragma mark - 获取所有区域
- (NSArray *)getAllAreas;

#pragma mark - 改变选择区域
- (void)changeAreaWithIndex:(NSInteger)index;

#pragma mark - 获取所有设备字典
- (NSDictionary *)getAllDevices;

#pragma mark - 公共设备列表
- (NSArray *)commonDevices;

#pragma mark - 实景图
- (UIImage *)actualImageWithViewpointType:(NSString *)viewpointType;

- (void)setActualImage:(UIImage *)actualImage withViewpointType:(NSString *)viewpointType;
#pragma mark - 登陆
- (void)loginWithUserName:(NSString *)userName
                      pwd:(NSString *)pwd
               remeberPwd:(BOOL)remeberPwd
                autoLogin:(BOOL)autoLogin
         completionHandle:(void (^)(BOOL isSuccess, NSString *errorDescription))completionHandle;

- (void)loadProcessDataListWithCompletionHandle:(void(^)(BOOL isSuccess, NSString *errorDescription))completionHandle;

#pragma mark - 注销登陆
- (void)logout;

#pragma mark - 保存日志
- (void)cacheLogWithModel:(LogInfo *)logInfo;

#pragma mark - 获取此次启动后的日志
- (NSDictionary *)logDict;

#pragma mark - 清除当前区域所有设备的配置信息
- (void)clearConfigOfAllDevice;

- (void)clearCacheData;
@end
