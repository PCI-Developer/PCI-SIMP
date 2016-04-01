//
//  Const.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/12.
//  Copyright © 2015年 东方佳联. All rights reserved.
//
#include <Foundation/Foundation.h>
//
//static NSString *ViewpointTypeVertical = @"俯视图";
//static NSString *ViewpointTypeFront = @"前";
//static NSString *ViewpointTypeBack = @"后";
//static NSString *ViewpointTypeLeft = @"左";
//static NSString *ViewpointTypeRight = @"右";

typedef NS_ENUM(NSUInteger, ViewPointType) {
    ViewPointTypeNone,
    ViewpointTypeVertical,
    ViewpointTypeFront,
    ViewpointTypeBack,
    ViewpointTypeLeft,
    ViewpointTypeRight
};

typedef NS_ENUM(NSUInteger, DataListType) {
    DataListTypeArea,
    DataListTypeDevice
};

typedef NS_ENUM(NSUInteger ,SocketState) {
    SocketStateDisConnected,
    SocketStateConnected
};

// 控制设备相关命令字
typedef NS_ENUM(NSUInteger, CMDType) {
    CMDTypeSetValue,
    CMDTypeOpen,            /***    打开       ***/
    CMDTypeClose,           /***    关闭       ***/
    CMDTypeGet,             /***    获取值      ***/
    CMDTypeConn,            /***    设备连接    ***/
    
    CMDTypeCaUp,            /***    摄         ***/
    CMDTypeCaDown,          /***               ***/
    CMDTypeCaLeft,          /***    像         ***/
    CMDTypeCaRight,         /***               ***/
    CMDTypeCaStop,          /***    头         ***/
    
    CMDTypeChangeChannel,   /***    电视       ***/
    
    CMDTypeConnFile,        /***    音         ***/
    CMDTypePlayFile,        /***    频         ***/
    CMDTypeStopFile,        /***    文         ***/
    CMDTypePauseFile,       /***    件         ***/
    CMDTypeConfigCameraFollow,
};

typedef NS_ENUM(NSUInteger, LogInfoType) {
    Log,
    Infomation
};

typedef NS_ENUM(NSUInteger, DeviceConnectState) {
    DeviceStateDisConnect = 0, // 未连接
    DeviceStateConnect, // 连接 - 无法确定打开关闭
    DeviceStateUnknow, // 连接 - 异常,无法操作
    DeviceStateOpen, // 连接 - 打开
    DeviceStateClose // 连接 - 关闭
};

typedef NS_ENUM(NSUInteger, DeviceOCState) {
    DeviceUnknow = 0, //
    DeviceOpen,
    DeviceClose
};

typedef NS_ENUM(NSUInteger, UserLevel) {
    UserLevelLow = 1,
    UserLevelHigh
};


typedef NS_ENUM(NSUInteger, ActualModeType) {
    ActualModeTypeConfig,  // 配置设备布局 -- 添加设备
    ActualModeTypeOpeartion, // 操作 -- 显示右上角图标
    ActualModeTypeNormal, // 正常模式
    ActualModeChangeScreen // 修改布局 -- 改变设备位置
};

typedef NS_ENUM(NSUInteger, DeviceViewImageStatus) {
    DeviceViewImageStatusForNormal = 0, // 正常
    DeviceViewImageStatusForHighlight, // 高亮 - 选中
    DeviceViewImageStatusForAllowConn, // 允许连接 - 选中设备,其他允许连接的设备
    DeviceViewImageStatusForShouldConn // 允许连接高亮 - 拖动设备,经过可连接设备时
};

#pragma mark - 单例
#define kSingleTon_M(classname) \
+ (instancetype)share##classname\
{ \
static classname *share = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
share = [classname new]; \
}); \
return share; \
}

#define kSingleTon_H(classname) \
+ (instancetype)share##classname;



#ifdef DEBUG
#define kLog(...) NSLog(__VA_ARGS__)
#else
#define kLog(...)
#endif


#define kDeviceTypeMusicFile @"声音文件"
#define kDeviceTypeCamera @"摄像头"
#define kDeviceTypeSoundBox @"音箱"
#define kDeviceTypeMic @"麦克"
#define kDeviceTypeLed @"大屏幕"
#define kDeviceTypeComputer @"电脑"
#define kDeviceTypeNoteBook @"笔记本"
#define kDeviceTypeTV @"电视"
#define kDeviceTypeDVD @"DVD"
#define kDeviceTypeVideoMeetting @"视频会议"
#define kDeviceTypeLights @"灯光"



#define kBottomMarginOfOCButton 40

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
#define kProtocolNetLink @"NETLINK" // 心跳包
// 协议命令字（服务器反馈）
#define kProtocolCMDFromServerToUpdate @"UPDATE_EQP_STATE"
#define kProtocolCMDFromServerForRespondControlDevice @"EQPCTRLOK"
#define kProtocolCMDFromServerForAreaList @"AREALIST"
#define kProtocolCMDFromServerForDeviceList @"UEQPLIST"
#define kProtocolCMDFromServerForLogin @"REOPERATOR"
#define kProtocolCMDFromServerForCameraFollow @"RSWCAMFLOW"
#define kProtocolCMDFromServerForXJList @"XJLIST"
#define kProtocolCMDFromServerForDoProcess @"XJCTRLOK"
// 协议命令字（iPad端发送）
#define kProtocolCMDByControlDevice @"EQPCTRl"
#define kProtocolCMDByCameraFollow @"SWCAMFLOW"
#define kProtocolGetAreaList @"ASKAREA"
#define kProtocolGetDeviceList @"ASKUEQPLIST"
#define kProtocolLogin @"ASKOPERATOR"
#define kProtocolGetXJList @"ASKXJLIST"
#define kProtocolCMDByDoProcess @"XJCTRL"
// 设备控制的相关命令字 -- 一般设备
#define kProtocolControlDeviceCMDOfOpen @"Open"
#define kProtocolControlDeviceCMDOfClose @"Close"
#define kProtocolControlDeviceCMDOfSetValue @"SetValue"
#define kProtocolControlDeviceCMDOfGet @"GetStatus"
#define kProtocolControlDeviceCMDofConn @"Conn"
// 设备控制相关命令字 -- 专用设备
#define kProtocolControlDeviceCMDofConnFile @"ConnFile" // 音频文件
#define kProtocolControlDeviceCMDofPlayFile @"PlayFile"
#define kProtocolControlDeviceCMDofStopFile @"StopFile"
#define kProtocolControlDeviceCMDofPauseFile @"PauseFile"
#define kProtocolControlDeviceCMDofUp @"Ca_Up" // 摄像头
#define kProtocolControlDeviceCMDofDown @"Ca_Down"
#define kProtocolControlDeviceCMDofLeft @"Ca_Left"
#define kProtocolControlDeviceCMDofRight @"Ca_Right"
#define kProtocolControlDeviceCMDofStop @"Ca_Stop"
#define kProtocolControlDeviceCMDofChangeChannel @"CngCnl"// 电视


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

#define kLocalUserKey @"localUser"

#define kNotificationWillEnterForeground @"applicationWillEnterForeground"


// 设备View 旋转相关
#define kIndicatorForRotationViewSize 20

// 流程列表选中颜色
#define kProcessTableViewCellSelectedColor [UIColor colorFromHexRGB:@"#00aaff"];


