//
//  Const.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/12.
//  Copyright © 2015年 东方佳联. All rights reserved.
//
#include <Foundation/Foundation.h>

static NSString *ViewpointTypeVertical = @"俯视图";
static NSString *ViewpointTypeFront = @"前";
static NSString *ViewpointTypeBack = @"后";
static NSString *ViewpointTypeLeft = @"左";
static NSString *ViewpointTypeRight = @"右";



typedef enum {
    DataListTypeArea,
    DataListTypeDevice
} DataListType;

typedef enum {
    SocketStateDisConnected,
    SocketStateConnected
}SocketState;

typedef enum {
    CMDTypeSetValue = 0,
    CMDTypeOpen,
    CMDTypeClose,
    CMDTypeGet,
    CMDTypeConn,
    CMDTypeCaUp,
    CMDTypeCaDown,
    CMDTypeCaLeft,
    CMDTypeCaRight,
    CMDTypeCaStop,
    CMDTypeChangeChannel,
    CMDTypeConfigCameraFollow
} CMDType;

typedef enum {
    Log,
    Infomation
} LogInfoType;

typedef enum {
    DeviceStateDisConnect = 0, // 未连接
    DeviceStateConnect, // 连接 - 无法确定打开关闭
    DeviceStateUnknow, // 连接 - 异常,无法操作
    DeviceStateOpen, // 连接 - 打开
    DeviceStateClose // 连接 - 关闭
} DeviceConnectState;

typedef enum {
    DeviceUnknow = 0, //
    DeviceOpen,
    DeviceClose
} DeviceOCState;

typedef enum {
    UserLevelLow = 1,
    UserLevelHigh
} UserLevel;


typedef enum {
    ActualModeTypeConfig,  // 配置设备布局 -- 添加设备
    ActualModeTypeOpeartion, // 操作 -- 显示右上角图标
    ActualModeTypeNormal, // 正常模式
    ActualModeChangeScreen // 修改布局 -- 改变设备位置
}ActualModeType;

typedef enum {
    DeviceViewImageStatusForNormal = 0, // 正常
    DeviceViewImageStatusForHighlight, // 高亮 - 选中
    DeviceViewImageStatusForAllowConn, // 允许连接 - 选中设备,其他允许连接的设备
    DeviceViewImageStatusForShouldConn // 允许连接高亮 - 拖动设备,经过可连接设备时
} DeviceViewImageStatus;

#define kTagForImageViewInWFFFollowHandsView 999 // 设备选中状态图标
#define kTagForDeviceImageInWFFFollowHandsView 99 // 设备图标
#define kRightViewTransitionType kCATransitionPush // 右侧子视图过场动画类型
#define kTagForLabelOfVolumeSlider 888 // 显示slider值的label


#define kTimeOut 5
#define kHead ([NSString stringWithFormat:@"%@%@", @"<", @"##>"])
#define kEnd @"<**>"

// 场景设置时
#define kFollowHandsViewOfDeviceWidth 100
#define kFollowHandsViewOfDeviceHeight 100

// 允许连接设备列表  连接时
#define kFollowHandsViewOfDeviceWidth1 80
#define kFollowHandsViewOfDeviceHeight1 80


#define kConfigOCKey @"OC"
#define kConfigConnKey @"CONN"
#define kConfigSetValueKey @"VALUE"
#define kConfigChangeChannel @"CHANGECHANNEL"


#pragma mark - 协议相关
#define kProtocolCMDFromServerToUpdate @"UPDATE_EQP_STATE"
#define kProtocolCMDFromServerForRespondControlDevice @"EQPCTRLOK"
#define kProtocolCMDFromServerForAreaList @"AREALIST"
#define kProtocolCMDFromServerForDeviceList @"UEQPLIST"
#define kProtocolCMDFromServerForLogin @"REOPERATOR"
#define kProtocolCMDFromServerForCameraFollow @"RSWCAMFLOW"

#define kProtocolCMDByControlDevice @"EQPCTRl"
#define kProtocolCMDByCameraFollow @"SWCAMFLOW"
#define kProtocolGetAreaList @"ASKAREA"
#define kProtocolGetDeviceList @"ASKUEQPLIST"
#define kProtocolLogin @"ASKOPERATOR"

#define kProtocolControlDeviceCMDOfOpen @"Open"
#define kProtocolControlDeviceCMDOfClose @"Close"
#define kProtocolControlDeviceCMDOfSetValue @"SetValue"
#define kProtocolControlDeviceCMDOfGet @"GetStatus"
#define kProtocolControlDeviceCMDofConn @"Conn"



#define kProtocolNetLink @"NETLINK" // 心跳包



#define kProtocolControlDeviceCMDofUp @"Ca_Up"
#define kProtocolControlDeviceCMDofDown @"Ca_Down"
#define kProtocolControlDeviceCMDofLeft @"Ca_Left"
#define kProtocolControlDeviceCMDofRight @"Ca_Right"
#define kProtocolControlDeviceCMDofStop @"Ca_Stop"
#define kProtocolControlDeviceCMDofChangeChannel @"CngCnl"


#pragma mark - 通知更新设备
#define kNotificationUpdateDevice @"NotificationUpdateDevice"
#define NotificationDidConnectedStateChange @"NotificationDidConnectedStateChange"

#define kViewWidth(view) view.frame.size.width
#define kViewHeight(view) view.frame.size.height
#define kScreenBounds ([UIScreen mainScreen].bounds)
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)
#define kColorWithRGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define kDocumentFilePath (NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject)
#define kActualImageFolder [kDocumentFilePath stringByAppendingPathComponent:@"Actual"]
#define kActualImageFilePathWithAreaName(areaname, viewpointType) [kActualImageFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"actualImage_%@_%@.png", (areaname), (viewpointType)]]
