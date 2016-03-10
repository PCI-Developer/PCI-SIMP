//
//  OPManager.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/25.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "OPManager.h"
#import "LogInfo.h"
#import "DeviceForUser.h"
#import "Area.h"
@implementation OPManager

kSingleTon_M(OPManager)
#pragma mark - 单个设备操作
- (void)deviceOpenWithDevice:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeOpen arg:nil deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

- (void)deviceCloseWithDevice:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeClose arg:nil deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

- (void)deviceSetValueWithDevice:(DeviceForUser *)device deviceValue:(NSString *)value resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeSetValue arg:value deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

- (void)deviceConnWithDevice:(DeviceForUser *)device otherDevice:(DeviceForUser *)otherDevice resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeConn arg:nil deviceForUser:device otherDevice:otherDevice resultBlock:resultBlock];
}

- (void)deviceStartPTZWithOrientation:(NSInteger)orientation deviceForUser:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    CMDType cmdType = CMDTypeCaStop;
    switch (orientation) {
        case 0:
            cmdType = CMDTypeCaUp;
            break;
            
        case 1:
            cmdType = CMDTypeCaDown;
            break;
            
        case 2:
            cmdType = CMDTypeCaLeft;
            break;
            
        case 3:
            cmdType = CMDTypeCaRight;
            break;
        default:
            
            break;
            
    }
    [self deviceOPWithCmdType:cmdType arg:nil deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

- (void)deviceStopPTZWtihDevice:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeCaStop arg:nil deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

// 频道
- (void)deviceChangeChannelWtihDevice:(DeviceForUser *)device channel:(NSString *)channel  resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeChangeChannel arg:channel deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

// 音频文件
- (void)deviceConnMusicFileWithFile:(DeviceForUser *)device otherDevice:(DeviceForUser *)otherDevice resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeConnFile arg:nil deviceForUser:device otherDevice:otherDevice resultBlock:resultBlock];
}
- (void)deviceControlMusicFileWithTag:(NSInteger)tag file:(DeviceForUser *)device resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    CMDType cmdType;
    switch (tag) {
        case 0:
            cmdType = CMDTypePlayFile;
            break;
        case 1:
            cmdType = CMDTypeStopFile;
            break;
        case 2:
            cmdType = CMDTypePauseFile;
            break;
            
        default:
            return;
    }
    [self deviceOPWithCmdType:cmdType arg:nil deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

// 配置摄像头跟随
- (void)deviceConfigCameraFollowWithDevice:(DeviceForUser *)device deviceValue:(NSString *)value resultBlock:(ControlResultWithDeviceBlock)resultBlock
{
    [self deviceOPWithCmdType:CMDTypeConfigCameraFollow arg:value deviceForUser:device otherDevice:nil resultBlock:resultBlock];
}

#pragma mark - 批量操作
- (void)deviceBatchOpenWithDevices:(NSArray *)deviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock
{
    [self deviceBatchOPWithCmdType:CMDTypeOpen arg:nil deviceForUsers:deviceArray otherDevices:nil resultBlock:resultBlock];
}
- (void)deviceBatchCloseWithDevices:(NSArray *)deviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock
{
    [self deviceBatchOPWithCmdType:CMDTypeClose arg:nil deviceForUsers:deviceArray otherDevices:nil resultBlock:resultBlock];
}
- (void)deviceBatchSetValueWithDevices:(NSArray *)deviceArray deviceValue:(NSString *)value resultBlock:(BatchControlResultWithDeviceBlock)resultBlock
{
    [self deviceBatchOPWithCmdType:CMDTypeSetValue arg:value deviceForUsers:deviceArray otherDevices:nil resultBlock:resultBlock];
}

- (void)deviceBatchConnWithDevice:(NSArray *)deviceArray otherDevice:(NSArray *)otherDeviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock
{
    [self deviceBatchOPWithCmdType:CMDTypeConn arg:nil deviceForUsers:deviceArray otherDevices:otherDeviceArray resultBlock:resultBlock];
}

// 频道
- (void)deviceBatchChangeChannelWithDevice:(NSArray *)deviceArray channel:(NSString *)channel  otherDevice:(NSArray *)otherDeviceArray resultBlock:(BatchControlResultWithDeviceBlock)resultBlock
{
    [self deviceBatchOPWithCmdType:CMDTypeChangeChannel arg:channel deviceForUsers:deviceArray otherDevices:nil resultBlock:resultBlock];
}

#pragma mark - 设备控制
- (void)deviceOPWithCmdType:(CMDType)cmdType arg:(NSString *)arg deviceForUser:(DeviceForUser *)deviceForUser otherDevice:(DeviceForUser *)otherDevice resultBlock:(ControlResultWithDeviceBlock)resultBlock
{

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LogInfo *logInfo = [LogInfo new];
        logInfo.type = Log;
        logInfo.UEQP_ID = deviceForUser.UEQP_ID;
        logInfo.cmdType = cmdType;
        logInfo.value = arg;
        logInfo.cmdNumber = [SocketManager shareSocketManager]->currentNum;
        logInfo.createDate = [[NSDate date] timeIntervalSince1970];
        logInfo.areaID = kCurrentArea.AreaID;
        logInfo.createUserID = kCurrentUser.ID;
        logInfo.otherUEQP_ID = otherDevice.UEQP_ID;
        logInfo.result = -1;
        
        NSString *ID = logInfo.UEQP_ID;
        if (cmdType == CMDTypeClose || cmdType == CMDTypeOpen || cmdType == CMDTypeCaDown || cmdType == CMDTypeCaUp || cmdType == CMDTypeCaLeft || cmdType == CMDTypeCaRight || cmdType == CMDTypeCaStop || cmdType == CMDTypePlayFile || cmdType == CMDTypeStopFile || cmdType == CMDTypePauseFile) { // 无参数命令
            logInfo.value = @"";
        } else if (cmdType == CMDTypeSetValue || cmdType == CMDTypeChangeChannel || cmdType == CMDTypeConfigCameraFollow){
            logInfo.value = arg;
        } else if (cmdType == CMDTypeConn || cmdType == CMDTypeConnFile) {
            logInfo.value = @"";
            ID = [logInfo.UEQP_ID stringByAppendingFormat:@",%@", logInfo.otherUEQP_ID];
        }
        
        // 保存操作日志
        kCacheLog(logInfo);
        kSaveLog(logInfo);
        
        // 操作
        [[SocketManager shareSocketManager] ctrlDevicesWithDevicesID:ID ControlType:logInfo.cmdType arg:logInfo.value resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
            // info - 设备编号,结果&设备编号,结果
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            // 处理信息元
            for (NSString *item in [info componentsSeparatedByString:@"&"]) {
                [resultDict setObject:[item componentsSeparatedByString:@","].lastObject forKey:[item componentsSeparatedByString:@","].firstObject];
            }
            
            LogInfo *model = kLogDict[@(cmdNumber)];
            

            
            model.result = isSuccess;
            kUpdateLog(model);
            
            // 输入源
            DeviceForUser *device = [[Common shareCommon] getDeviceWithUEQP_ID:logInfo.UEQP_ID];
            
            // 输出源
            DeviceForUser *otherDevice = [[Common shareCommon] getDeviceWithUEQP_ID:logInfo.otherUEQP_ID];
            
            if (isSuccess) {
                if (model.cmdType == CMDTypeClose || model.cmdType == CMDTypeOpen) { // 开关 - 更新设备状态
                    // 操作后,保存配置
                    if ([resultDict[device.UEQP_ID] intValue] == 1) { // 判断该设备是否操作成功
                        [device.currentConfigs setObject:@(model.cmdType) forKey:kConfigOCKey];
                        
                        device.deviceOCState = (DeviceOCState)model.cmdType;
                        //                    kLog(@"设备更新发出通知 : %@", device);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:device];
                    } else {
                        kLog(@"设备编号 : %@ 操作失败", device.UEQP_ID);
                    }
                } else if (model.cmdType == CMDTypeSetValue){// 更新设备值
                    // 操作后,保存配置
                    [device.currentConfigs setObject:model.value forKey:kConfigSetValueKey];
                    
                    device.value = model.value;
                    //                kLog(@"设备更新发出通知 : %@", device);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:device];
                } else if (model.cmdType == CMDTypeConn) {
                    // 操作后,保存配置
                    [otherDevice.currentConfigs setObject:device.UEQP_ID forKey:kConfigConnKey];
                    otherDevice.connectedDevice = device;
                    //                kLog(@"设备更新发出通知 : %@", otherDevice);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:otherDevice];
                } else if (model.cmdType == CMDTypeChangeChannel) {
                    [device.currentConfigs setObject:model.value forKey:kConfigChangeChannel];
                    device.channel = model.value;
                } else if (model.cmdType == CMDTypeConfigCameraFollow) {
                    // 0 或者 1 说明是摄像头设置开启关闭
                    if ([model.value isEqualToString:@"0"] || [model.value isEqualToString:@"1"]) {
                        device.needFollow = [model.value boolValue];
                    } else { // 其他设备设置的跟随摄像头
                        device.followUEQP_ID = model.value;
                    }
                }
            } else {
                kLog(@"网络异常,请检查后重试");
            }
            if (resultBlock) {
                resultBlock(isSuccess, cmdNumber, device, otherDevice);
            }
        }];
//    });
    
    
}

#pragma mark - 批量控制
- (void)deviceBatchOPWithCmdType:(CMDType)cmdType arg:(NSString *)arg deviceForUsers:(NSArray *)devices otherDevices:(NSArray *)otherDevices resultBlock:(BatchControlResultWithDeviceBlock)resultBlock
{

//    if (cmdType == CMDTypeSetValue || cmdType == CMDTypeConn || cmdType == CMDTypeCaDown || cmdType == CMDTypeCaUp || cmdType == CMDTypeCaLeft || cmdType == CMDTypeCaRight || cmdType == CMDTypeCaStop) {
//        BOOL flag = YES;
//        for (DeviceForUser *model in devices) {
//            if (model.deviceOCState != DeviceOpen) {
//                flag = NO;
//                break;
//            }
//        }
//        
//        if (!flag) {
//            __weak typeof(self) weakSelf = self;
//            [self deviceBatchOpenWithDevices:devices resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *others) {// others不能与外部的otherDevices同名!!
//                if (isSuccess) {
//                    [weakSelf deviceBatchOPWithCmdType:cmdType arg:arg deviceForUsers:devices otherDevices:otherDevices resultBlock:resultBlock];
//                } else {
//                    kLog(@"设备打开失败");
//                }
//            }];
//            return;
//        }
//    }
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LogInfo *logInfo = [LogInfo new];
        logInfo.type = Log;
        //    logInfo.UEQP_ID = deviceForUser.UEQP_ID;
        logInfo.cmdType = cmdType;
        logInfo.value = arg;
        logInfo.cmdNumber = [SocketManager shareSocketManager]->currentNum;
        logInfo.createDate = [[NSDate date] timeIntervalSince1970];
        logInfo.areaID = kCurrentArea.AreaID;
        logInfo.createUserID = kCurrentUser.ID;
        //    logInfo.otherUEQP_ID = otherDevice.UEQP_ID;
        logInfo.result = -1;
        
        NSMutableString *IDs = [NSMutableString string];
        for (DeviceForUser *model in devices) {
            [IDs appendFormat:@"%@,", model.UEQP_ID];
        }
        if (IDs.length > 0) {
            [IDs deleteCharactersInRange:NSMakeRange(IDs.length - 1, 1)];
        }
        
        NSMutableString *otherIDs = [NSMutableString string];
        for (DeviceForUser *model in otherDevices) {
            [otherIDs appendFormat:@"%@,", model.UEQP_ID];
        }
        if (otherIDs.length > 0) {
            [otherIDs deleteCharactersInRange:NSMakeRange(otherIDs.length - 1, 1)];
        }
        
        logInfo.UEQP_ID = IDs;
        logInfo.otherUEQP_ID = otherIDs;
        
        
        
        NSString *ID = logInfo.UEQP_ID;
        if (cmdType == CMDTypeClose || cmdType == CMDTypeOpen  || cmdType == CMDTypeCaDown || cmdType == CMDTypeCaUp || cmdType == CMDTypeCaLeft || cmdType == CMDTypeCaRight || cmdType == CMDTypeCaStop) { // 开关
            logInfo.value = @"";
        } else if (cmdType == CMDTypeSetValue){
            logInfo.value = arg;
        } else if (cmdType == CMDTypeConn) {
            logInfo.value = @"";
            ID = [logInfo.UEQP_ID stringByAppendingFormat:@",%@", logInfo.otherUEQP_ID];
        }
        
        // 保存操作日志
        kCacheLog(logInfo);
        kSaveLog(logInfo);
        // 操作
        [[SocketManager shareSocketManager] ctrlDevicesWithDevicesID:ID ControlType:logInfo.cmdType arg:logInfo.value resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
            // info - 设备编号,结果&设备编号,结果
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            // 处理信息元
            for (NSString *item in [info componentsSeparatedByString:@"&"]) {
                [resultDict setObject:[item componentsSeparatedByString:@","].lastObject forKey:[item componentsSeparatedByString:@","].firstObject];
            }
            
            
            LogInfo *model = kLogDict[@(cmdNumber)];
            
            model.result = isSuccess;
            kUpdateLog(model);
            
            // 输入源
            NSMutableArray *devicesArray = [NSMutableArray array];
            if (logInfo.UEQP_ID.length > 0) {
                for (NSString *ID in [logInfo.UEQP_ID componentsSeparatedByString:@","]) {
                    DeviceForUser *model = [[Common shareCommon] getDeviceWithUEQP_ID:ID];
                    [devicesArray addObject:model];
                }
            }
            
            // 输出源
            NSMutableArray *otherDevicesArray = [NSMutableArray array];
            if (logInfo.otherUEQP_ID.length > 0) {
                for (NSString *ID in [logInfo.otherUEQP_ID componentsSeparatedByString:@","]) {
                    DeviceForUser *model = [[Common shareCommon] getDeviceWithUEQP_ID:ID];
                    [otherDevicesArray addObject:model];
                }
            }
            
            if (isSuccess) {
                // 统一更新设备[也可放在上面循环中,此处可读性强]
                for (DeviceForUser *device in devicesArray) {
                    if (model.cmdType == CMDTypeClose || model.cmdType == CMDTypeOpen || model.cmdType == CMDTypePlayFile || model.cmdType == CMDTypeStopFile || model.cmdType == CMDTypePauseFile) { // 开关
                        // 操作后,保存配置
                        if ([resultDict[device.UEQP_ID] intValue] == 1) { // 判断该设备是否操作成功
                            [device.currentConfigs setObject:@(model.cmdType) forKey:kConfigOCKey];
                            if (model.cmdType > 2) { // 音频文件
                                if (model.cmdType > CMDTypePlayFile) { // 暂停或者停止
                                    device.deviceOCState = DeviceClose;
                                } else {
                                    device.deviceOCState = DeviceOpen;
                                }
                            } else { // 其他设备
                                device.deviceOCState = (DeviceOCState)model.cmdType;
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:device];
                        } else {
                            kLog(@"设备编号 : %@ 开关操作失败", device.UEQP_ID);
                        }
                    } else if (model.cmdType == CMDTypeSetValue){
                        // 操作后,保存配置
                        [device.currentConfigs setObject:model.value forKey:kConfigSetValueKey];
                        device.value = model.value;
                        //                    kLog(@"设备更新发出通知 : %@", device);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:device];
                    } else if (model.cmdType == CMDTypeConn || model.cmdType == CMDTypeConnFile) {
                        // 连接操作,则devicesArray必定个数为1[输入源为1 输出源为多]
                        for (DeviceForUser *otherDevice in otherDevicesArray) {
                            // 操作后,保存配置
                            [otherDevice.currentConfigs setObject:device.UEQP_ID forKey:kConfigConnKey];
                            otherDevice.connectedDevice = device;
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:otherDevice];
                        }
                    } else if (model.cmdType == CMDTypeChangeChannel) {
                        [device.currentConfigs setObject:model.value forKey:kConfigChangeChannel];
                        device.channel = model.value;
                    }
                }
            } else {
                kLog(@"网络异常,请检查后重试");
            }
            
            if (resultBlock) {
                resultBlock(isSuccess, cmdNumber, devicesArray, otherDevices);
            }
        }];
}






@end
