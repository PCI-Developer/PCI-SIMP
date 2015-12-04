//
//  LogInfo.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/18.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "LogInfo.h"
#import "DeviceForUser.h"
@interface LogInfo ()

@end

@implementation LogInfo


- (NSString *)description
{
    
    NSString *opString = @"";
    NSString *deviceName = nil;
    NSString *deviceType = nil;
    if ([self.UEQP_ID componentsSeparatedByString:@","].count > 1 || [self.otherUEQP_ID componentsSeparatedByString:@","].count > 1) {
        // 操作字段
        opString = @"批量";
        // 设备类型
        deviceType = kDeviceTypeInfo([[Common shareCommon] getDeviceWithUEQP_ID:[self.UEQP_ID componentsSeparatedByString:@","].firstObject].UEQP_Type)[@"name"];
        
        // 设备名称
        NSMutableString *devicesName = [NSMutableString string];
        
        for (NSString *ID in [self.UEQP_ID componentsSeparatedByString:@","]) {
            DeviceForUser *model = [[Common shareCommon] getDeviceWithUEQP_ID:ID];
            [devicesName appendFormat:@"%@,", model.UEQP_Name];
        }
        if (devicesName.length > 0) {
            [devicesName deleteCharactersInRange:NSMakeRange(devicesName.length - 1, 1)];
        }
        
        
        deviceName = devicesName;
    } else {
        DeviceForUser *deviceForUser = [[Common shareCommon] getDeviceWithUEQP_ID:self.UEQP_ID];
        deviceType = kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"];

        deviceName = deviceForUser.UEQP_Name;
    }
    
    
    if (self.cmdType == CMDTypeOpen) {
        return [NSString stringWithFormat:@"%@打开设备 类型:%@ 名称:%@", opString, deviceType, deviceName];
    } else if (self.cmdType == CMDTypeClose) {
        return [NSString stringWithFormat:@"%@关闭设备 类型:%@ 名称:%@", opString, deviceType, deviceName];
    } else if (self.cmdType == CMDTypeGet) {
        return [NSString stringWithFormat:@"%@获取设备信息 类型:%@ 名称:%@", opString, deviceType, deviceName];
    } else if (self.cmdType == CMDTypeSetValue) {
        return [NSString stringWithFormat:@"%@修改设备值 类型:%@ 名称:%@", opString, deviceType, deviceName];
    } else if (self.cmdType == CMDTypeConn){
        return [NSString stringWithFormat:@"类型:%@ 名称:%@ %@连接%ld个%@", deviceType, deviceName, opString, (long)[self.otherUEQP_ID componentsSeparatedByString:@","].count,
                kDeviceTypeInfo([[Common shareCommon] getDeviceWithUEQP_ID:[self.otherUEQP_ID componentsSeparatedByString:@","].firstObject].UEQP_Type)[@"name"]];
    } else if (self.cmdType == CMDTypeCaUp || self.cmdType == CMDTypeCaDown || self.cmdType == CMDTypeCaLeft || self.cmdType == CMDTypeCaRight) {
        return [NSString stringWithFormat:@"类型:%@ 名称:%@ 云台%@控制,开始调整方向.", deviceType, deviceName, opString];
    } else if (self.cmdType == CMDTypeCaStop) {
        return [NSString stringWithFormat:@"类型:%@ 名称:%@ 云台%@控制,停止调整方向.", deviceType, deviceName, opString];
    } else if (self.cmdType == CMDTypeChangeChannel) {
        return [NSString stringWithFormat:@"类型:%@ 名称:%@ 频道%@变更为:%@", deviceType, deviceName, opString, self.value];
    } else if (self.cmdType == CMDTypeConfigCameraFollow) {
        if ([self.value isEqualToString:@"0"] || [self.value isEqualToString:@"1"]) {
            return [NSString stringWithFormat:@"类型:%@ 名称:%@ %@摄像头跟随", deviceType, deviceName, [self.value boolValue] ? @"打开" : @"关闭"];
        } else {
            return [NSString stringWithFormat:@"类型:%@ 名称:%@ 设置跟随摄像头ID%@", deviceType, deviceName, self.value];
        }
    }
    return nil;
}

@end
