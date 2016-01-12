//
//  ActualModeViewController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/14.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "ActualModeViewController.h"
#import "SystemMainViewController.h"
#import "DeviceCollectionViewCell.h"
#import "WFFFollowHandsView.h"
#import "DeviceForUser.h"
#import "WFFDropdownList.h"
#import "Area.h"
#import "DetaiLayoutOfAreaByViewpointType.h"
#import "PopMenu.h"
#import "LogInfo.h"
#import "AutoSizeCollectionView.h"
#import "OPManager.h"

#import "DeviceInfoBaseView.h"

#import "UIView+AutoLayout.h"

#import "CameraFollowConfigView.h"

#import "ProcessView.h"

#import "AppDelegate.h"
/**
 枚举值.当前置顶的view类型
 */
typedef enum
{
    TopViewTypeNone = 0,
    TopViewTypeForDeviceInfoView,
    TopViewTypeForProcessView,
    TopViewTypeForCommonDeviceView
} TopViewType;

/**
 底部其他视图的种类
 */
typedef enum
{
    OtherViewTypeCommonDevice,
    OtherViewTypeMusicFile
} OtherViewType;

@interface ActualModeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, WFFFollowHandsViewDelegate,UIGestureRecognizerDelegate, WFFDropdownListDelegate, DeviceInfoBaseViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *movingViewDict; // 存放正在移动的所有view的字典

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *actualImageView;
@property (nonatomic, strong) UITapGestureRecognizer *actualImageViewTapGR;

// 遮罩层(包含collectionView
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIView *screenConfigShadeView;
@property (weak, nonatomic) IBOutlet UICollectionView *deviceCollectionView;@property (weak, nonatomic) IBOutlet UIButton *cancelButtonForAddScreen;
@property (weak, nonatomic) IBOutlet UIButton *okButtonForAddScreen;
- (IBAction)cancelButtonActionForAddScreen:(UIButton *)sender;
- (IBAction)okButtonActionForAddScreen:(UIButton *)sender;

- (IBAction)putInOrderButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *processBackgroundView;
@property (nonatomic, strong) ProcessView *processView;
- (IBAction)processBackgroundViewTapGRAction:(UITapGestureRecognizer *)sender;
// 操作层
@property (weak, nonatomic) IBOutlet UIView *operatioinView;

- (IBAction)showProcessViewButtonAction:(UIButton *)sender;
- (IBAction)addDeviceButtonAction:(UIButton *)sender;

- (IBAction)changeActualImageButtonAction:(UIButton *)sender;
- (IBAction)changeCurrenScreenButtonAction:(UIButton *)sender;
// 修改场景时出现的按钮
@property (weak, nonatomic) IBOutlet UIImageView *trashImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)saveButtonAction:(UIButton *)sender;
- (IBAction)cancelButtonAction:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *devicesArray;

@property (nonatomic, strong) WFFFollowHandsView *currentHandsView;

// 当前场景所有设备的布局
@property (nonatomic, strong) NSArray *detailLayoutOfAreaByViewpointTypeArray;

@property (nonatomic, assign) ActualModeType currentMode;
// 当前视角
@property (nonatomic, copy) NSString *currentViewpointType;
// 上一次选择的视角(当选择视角,不配置底图用于自动跳转的)
@property (nonatomic, copy) NSString *lastViewpointType;
// 放置设备信息界面的View
@property (weak, nonatomic) IBOutlet UIView *deviceInfoBackgroundView;
/**
 *  设备详细信息界面
 */
@property (nonatomic, strong) DeviceInfoBaseView *deviceInfoView;

/**
 *  频道数组
 */
@property (nonatomic, strong) NSArray *channelArray;
/**
 *  摄像头跟随配置界面
 */
@property (nonatomic, strong) CameraFollowConfigView *cameraFollowConfigView;

// 显示快速选择
- (IBAction)showQuickChooseButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *showQuickChooseButton;

/**
 *  上一次选中设备
 *  当设备调整方向的时候,另一个触摸点隐藏掉设备信息界面.会触发方向按钮的cancel的Action,执行代理TouchUp.
 *  而此时self.selectedDevice已经为空.导致执行 停止方向调整的指令 会传送空的device.
 */
@property (nonatomic, strong) DeviceForUser *lastSelectedDevice;
/**
 *  选中设备
 */
@property (nonatomic, strong) DeviceForUser *selectedDevice;


/**
 *  切换视角按钮的父视图
 */
@property (weak, nonatomic) IBOutlet UIView *viewpointButtonsView;

/**
 *  视角类型数组
 */
@property (nonatomic, strong) NSArray *viewpointTypeArray;

/**
 *  视角切换按钮的响应事件
 *
 *  @param sender 按钮 - 根据Tag区分切换哪一个视角
 */
- (IBAction)viewpointButtonAction:(UIButton *)sender;

/**
 *  当前区域的所有设备类型
 */
@property (nonatomic, strong) NSArray *allTypeOfDevicesArray;

/**
 *  公共设备的collectionView
 */
@property (weak, nonatomic) IBOutlet AutoSizeCollectionView *commonDeviceCollectionView;
@property (weak, nonatomic) IBOutlet UIView *commonDeviceBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *musicFileButton;
@property (weak, nonatomic) IBOutlet UIButton *commonDeviceButton;
@property (nonatomic, assign) OtherViewType selectedOtherViewType;
- (IBAction)otherViewButtonAction:(UIButton *)sender;

@end

@implementation ActualModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 存放正在移动的设备view, key:设备ID
    self.movingViewDict = [NSMutableDictionary dictionary];
    
    self.channelArray = @[@"切换频道", @"TV", @"HDMI1", @"HDMI2", @"DVI-I", @"USB", @"VGA"];
    // 新建场景时的collectionView注册Cell
    [self.deviceCollectionView registerNib:[UINib nibWithNibName:@"DeviceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"deviceCell"];
    [self.commonDeviceCollectionView registerNib:[UINib nibWithNibName:@"DeviceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"commonDeviceCell"];
    //
    self.actualImageViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actualImageViewTapGRAction:)];
    [self.actualImageView addGestureRecognizer:self.actualImageViewTapGR];
    
    
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 从后台返回的通知 (返回后,所有动画停止,必须手动layoutDevice.否则在演示版[不会收到设备更新通知]会出现空的设备图标)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:kNotificationWillEnterForeground object:nil];
    
    self.viewpointTypeArray = @[ViewpointTypeVertical, ViewpointTypeFront, ViewpointTypeBack, ViewpointTypeLeft, ViewpointTypeRight];
    
    self.allTypeOfDevicesArray = kAllTypeOfCurrentDevices;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveDeviceUpdateNotification:) name:kNotificationUpdateDevice object:nil];
    
    // 第一次进来的时候,为nil
    if (!_lastViewpointType) {
        self.currentViewpointType = self.viewpointTypeArray[0];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationUpdateDevice object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// BEGIN 旋转前也会调用这句
// 视图切换时,对子视图的frame进行了设置. 因此子视图的frame如果不再手动改变的话,是恒定值,里面的子视图也就不会按autolaytou来布局
// 也可以代码添加view后,给view添加约束
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.commonDeviceCollectionView invalidateIntrinsicContentSize];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 从后台返回
- (void)applicationWillEnterForeground:(NSNotification *)sender
{
    [self setCurrentMode:ActualModeTypeNormal];
}

#pragma mark 屏幕旋转
- (void)handleDeviceOrientationDidChange:(NSNotification *)notification
{
    [self.commonDeviceCollectionView invalidateIntrinsicContentSize];
}
// END

#pragma mark - 设备更新通知
- (void)recieveDeviceUpdateNotification:(NSNotification *)sender
{
    DeviceForUser *device = sender.object;
    if (([kCommonDevices containsObject:device] && self.selectedOtherViewType == OtherViewTypeCommonDevice) ||
        ([kMusicFile containsObject:device] && self.selectedOtherViewType == OtherViewTypeMusicFile) ) {// 公共设备 || 音频文件
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.selectedOtherViewType == OtherViewTypeCommonDevice ? kCommonDevices : kMusicFile indexOfObject:device] inSection:0];
        DeviceCollectionViewCell *cell = (DeviceCollectionViewCell *)[self.commonDeviceCollectionView cellForItemAtIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.selectedDevice == device) {
                // 更新界面的图标和值
                [self updateUIOfDeviceInfoView];
            }
            
            cell.deviceImageView.image = [UIImage imageNamed:[device imageNameByStatusRunAnimationOnImageView:cell.deviceImageView]];
        });
    } else {
        //    kLog(@"%@ %@", device.UEQP_Name, device.value);
        WFFFollowHandsView *deviceView = (WFFFollowHandsView *)[self.contentView viewWithTag:[device AutoID]];
        if (deviceView) { // 已经布局
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.selectedDevice == device) {
                    // 更新界面的图标和值
                    [self updateUIOfDeviceInfoView];
                }
                
                UIImageView *deviceImage = [deviceView viewWithTag:kTagForDeviceImageInWFFFollowHandsView];
                NSString *imageName = [device imageNameByStatusRunAnimationOnImageView:deviceImage];
                deviceImage.image = [UIImage imageNamed:imageName];
            });
        }
    }
}

#pragma mark - 获取指定设备类型的所有布局模型
- (NSArray *)getAllDetailOfAreaScreenWithDeviceType:(NSString *)deviceType
{
    NSMutableArray *sameDeviceTypeArray = [NSMutableArray array];
    // 遍历获取同类型的所有设备布局模型的数组
    for (DetaiLayoutOfAreaByViewpointType *model in self.detailLayoutOfAreaByViewpointTypeArray) {
        if ([model.device.UEQP_Type isEqualToString:deviceType]) {// 包含该key
            [sameDeviceTypeArray addObject:model];
        }
    }
    return sameDeviceTypeArray;
}

#pragma mark - 设备详情页
- (CameraFollowConfigView *)cameraFollowConfigView
{
    if (!_cameraFollowConfigView) {
        _cameraFollowConfigView = [[UINib nibWithNibName:@"CameraFollowConfigView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
        [_cameraFollowConfigView setHidden:YES animated:NO];
        [self.view insertSubview:_cameraFollowConfigView belowSubview:_deviceInfoBackgroundView];
        [_cameraFollowConfigView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_deviceInfoBackgroundView withOffset:-20];
        [_cameraFollowConfigView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_deviceInfoBackgroundView];
        [_cameraFollowConfigView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_deviceInfoBackgroundView];
        [_cameraFollowConfigView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:_deviceInfoBackgroundView];
    }
    return _cameraFollowConfigView;
}

static BOOL isDeviceInfoOrientationButtonTouchDown = NO;
#pragma mark - DeviceInfoBaseViewDelegate
- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView orientationButtonTouchDown:(UIButton *)button
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        return;
    }
    isDeviceInfoOrientationButtonTouchDown = YES;
    kDeviceStartPTZ(self.selectedDevice, button.tag, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
        if (isSuccess) {
            kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 开始调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
        } else {
            //            [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
        }
    });
}

- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView orientationButtonTouchUp:(UIButton *)button
{
    if (!isDeviceInfoOrientationButtonTouchDown) { // 按下去没权限
        return;
    }
    isDeviceInfoOrientationButtonTouchDown = NO;
    // 当设备信息界面隐藏时,会触发cancel的Action,执行该代理方法.此时selectedDevice已经为nil.只能根据lastSelectedDeviced; 否则会导致内部发送消息拼接参数的时候崩溃
    
    kDeviceStopPTZ(self.selectedDevice ? self.selectedDevice : self.lastSelectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
        if (isSuccess) {
            
            kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 停止调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
        } else {
            //            [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
        }
    });
}

- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView channelIndexChanged:(NSInteger)channelIndex
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        return;
    }
    
    if (channelIndex == 0) {
        return;
    }
    NSString *channel = self.channelArray[channelIndex];
    if (self.selectedDevice) {
        [[OPManager shareOPManager] deviceChangeChannelWtihDevice:self.selectedDevice channel:channel resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 切换频道%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        }];
    } /*else { // 批量
        NSArray *selectedDetailOfAreaScreen = [self getAllDetailOfAreaScreenWithDeviceType:self.selectedDeviceType];
        NSMutableArray *deviceArray = [NSMutableArray array];
        for (DetaiLayoutOfAreaByViewpointType *model in selectedDetailOfAreaScreen) {
            [deviceArray addObject:model.device];
        }
        [[OPManager shareOPManager] deviceBatchChangeChannelWithDevice:deviceArray channel:channel otherDevice:nil resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
            if (isSuccess) {
                kLog(@"类型:%@ %ld个设备 批量切换频道%@",kDeviceTypeInfo([devices.firstObject UEQP_Type])[@"name"], (long)devices.count, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        }];
    }*/
    
}

- (void)deviceInfoViewCloseButtonClicked:(DeviceInfoBaseView *)deviceInfoView
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        return;
    }
    if (self.selectedDevice) {
        kDeviceClose(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 关闭%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
            
        });
    }/* else { // 批量
        NSArray *selectedDetailOfAreaScreen = [self getAllDetailOfAreaScreenWithDeviceType:self.selectedDeviceType];
        NSMutableArray *deviceArray = [NSMutableArray array];
        for (DetaiLayoutOfAreaByViewpointType *model in selectedDetailOfAreaScreen) {
            [deviceArray addObject:model.device];
        }
        kDeviceBatchClose(deviceArray, ^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
            if (isSuccess) {
                kLog(@"类型:%@ %ld个设备 批量关闭%@",kDeviceTypeInfo([devices.firstObject UEQP_Type])[@"name"], (unsigned long)devices.count, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    }
    */
    
}

- (void)deviceInfoViewOpenButtonClicked:(DeviceInfoBaseView *)deviceInfoView
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        return;
    }
    if (self.selectedDevice) {
        kDeviceOpen(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 打开%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    }/* else { // 批量
        NSArray *selectedDetailOfAreaScreen = [self getAllDetailOfAreaScreenWithDeviceType:self.selectedDeviceType];
        NSMutableArray *deviceArray = [NSMutableArray array];
        for (DetaiLayoutOfAreaByViewpointType *model in selectedDetailOfAreaScreen) {
            [deviceArray addObject:model.device];
        }
        kDeviceBatchOpen(deviceArray, ^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
            if (isSuccess) {
                kLog(@"类型:%@ %ld个设备 批量打开%@",kDeviceTypeInfo([devices.firstObject UEQP_Type])[@"name"], (long)devices.count, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    }*/
    
}

- (void)deviceInfoViewSliderLeaveFoucsWithValue:(CGFloat)value
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        // 滑块归位
        [self updateUIOfDeviceInfoView];
        return;
    }
    if (self.selectedDevice) {
        CGFloat maxValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"maxValue"] floatValue];
        CGFloat minValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"minValue"] floatValue];
        NSString *valueForSet = [NSString stringWithFormat:@"%.2f", ((maxValue - minValue) * value + minValue)];
        
        [[OPManager shareOPManager] deviceSetValueWithDevice:self.selectedDevice deviceValue:valueForSet resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 修改设备值为:%@ %@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, deviceForUser.value, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        }];
    } /*else { // 批量
        //        CGFloat maxValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"maxValue"] floatValue];
        CGFloat minValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"minValue"] floatValue];
        NSString *valueForSet = [NSString stringWithFormat:@"%.2f", minValue];
        
        NSArray *selectedDetailOfAreaScreen = [self getAllDetailOfAreaScreenWithDeviceType:self.selectedDeviceType];
        NSMutableArray *deviceArray = [NSMutableArray array];
        for (DetaiLayoutOfAreaByViewpointType *model in selectedDetailOfAreaScreen) {
            [deviceArray addObject:model.device];
        }
        [[OPManager shareOPManager] deviceBatchSetValueWithDevices:deviceArray deviceValue:valueForSet resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
            if (isSuccess) {
                kLog(@"类型:%@ %ld个设备 批量修改设备值%@",kDeviceTypeInfo([devices.firstObject UEQP_Type])[@"name"], (long)devices.count, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        }];
    }*/
    
}

- (void)deviceInfoViewVolumeAddButtonClicked
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        // 滑块归位
        [self updateUIOfDeviceInfoView];
        return;
    }

    if (self.selectedDevice) {
        CGFloat maxValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"maxValue"] floatValue];
        CGFloat minValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"minValue"] floatValue];
        CGFloat dValue = (maxValue - minValue) / 100.0;
        if ([self.selectedDevice.value floatValue] == maxValue) {
            return;
        }
        // 改变后的value
        CGFloat valueForSet = [self.selectedDevice.value floatValue] + dValue;
        if (valueForSet > maxValue) {
            valueForSet = maxValue;
        }


        [[OPManager shareOPManager] deviceSetValueWithDevice:self.selectedDevice deviceValue:[NSString stringWithFormat:@"%.0f", valueForSet] resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 修改设备值为:%@ %@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, deviceForUser.value, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        }];
    }/* else { // 批量
    }*/
}
//
- (void)deviceInfoViewVolumeMinusButtonClicked
{
    if (![self checkPermissionsByDevice:self.selectedDevice]) {
        // 滑块归位
        [self updateUIOfDeviceInfoView];
        return;
    }
    if (self.selectedDevice) {
        CGFloat maxValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"maxValue"] floatValue];
        CGFloat minValue = [kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"minValue"] floatValue];
        CGFloat dValue = (maxValue - minValue) / 100.0;
        if ([self.selectedDevice.value floatValue] == minValue) {
            return;
        }
        // 改变后的value
        CGFloat valueForSet = [self.selectedDevice.value floatValue] - dValue;
        if (valueForSet < minValue) {
            valueForSet = minValue;
        }


        [[OPManager shareOPManager] deviceSetValueWithDevice:self.selectedDevice deviceValue:[NSString stringWithFormat:@"%.0f", valueForSet] resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 修改设备值为:%@ %@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, deviceForUser.value, isSuccess ? @"成功" : @"失败");
            } else {
                //                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        }];
    }/* else {  // 批量
      
    }*/
}

- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView cameraFollowButtonClicked:(UIButton *)button
{
    // 先设置下拉列表的数据源,再设置选中的摄像头,顺序不可改变
    self.cameraFollowConfigView.cameraArray = kGetDevicesWithType(@"摄像头");
    self.cameraFollowConfigView.selectedUEQP_ID = self.selectedDevice.followUEQP_ID;
    __weak typeof(self) weakSelf = self;
    self.cameraFollowConfigView.applyButtonClickedBlock = ^(DeviceForUser *camera) {
        kLog(@"%@", camera);
        NSString *followUEQP_ID = camera ? camera.UEQP_ID : nil;
        kCameraFollow(weakSelf.selectedDevice, followUEQP_ID, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            // 更新界面.失败则恢复之前配置,成功则更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:deviceForUser];
            });
            if (isSuccess) {
                if ([deviceForUser.UEQP_Type isEqualToString:@"摄像头"]) {
                    kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ %@摄像头跟随功能",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, deviceForUser.needFollow ? @"开启" : @"关闭");
                } else {
                    kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 设置摄像头跟随:%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, [[Common shareCommon] getDeviceWithUEQP_ID:deviceForUser.followUEQP_ID]);
                }
            }
        });
    };
    // button的selected状态先改变
    [self.cameraFollowConfigView setHidden:!button.selected animated:YES];
}

- (void)deviceInfoViewCheckBoxClicked:(DeviceInfoBaseView *)deviceInfoView
{
    kCameraFollow(self.selectedDevice, ([NSString stringWithFormat:@"%d", self.deviceInfoView.isSelected]), ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
        // 更新界面.失败则恢复之前配置,成功则更新
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:deviceForUser];
        });
        if (isSuccess) {
            if ([deviceForUser.UEQP_Type isEqualToString:@"摄像头"]) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ %@摄像头跟随功能",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, deviceForUser.needFollow ? @"开启" : @"关闭");
            } else {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 设置摄像头跟随:%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, [[Common shareCommon] getDeviceWithUEQP_ID:deviceForUser.followUEQP_ID]);
            }
        }
    });

}
#pragma mark - 根据当前置顶的view,隐藏无用的view,或者显示有用界面
- (void)updateViewHideOrShowByType:(TopViewType)topViewType
{
    __weak typeof(self) weakSelf = self;
    switch (topViewType) {
        case TopViewTypeNone: // 隐藏所有
            // 显示操作界面
            if (self.operatioinView.hidden) {
                [self.operatioinView setHidden:NO animated:YES];
            }
            
            // 隐藏公共设备
            if (self.commonDeviceBackgroundView.hidden == NO) {
                [self.commonDeviceBackgroundView setHidden:YES animated:YES completionHandle:^{
                    if (weakSelf.showQuickChooseButton.hidden) {
                        [weakSelf.showQuickChooseButton setHidden:NO animated:YES];
                    }
                }];
            } else {
                if (self.showQuickChooseButton.hidden) {
                    [self.showQuickChooseButton setHidden:NO animated:YES];
                }
            }
            
            // 隐藏设备信息界面
            if (self.deviceInfoBackgroundView.hidden == NO) {
                [self.deviceInfoBackgroundView setHidden:YES animated:YES];
            }
            // 隐藏流程界面
            if (self.processBackgroundView.hidden == NO) {
                [self.processBackgroundView setHidden:YES animated:YES];
            }
            self.selectedDevice = nil;
            // 公共设备 && 快速选择
            [self setCellHighlightWithCollectionView:self.commonDeviceCollectionView indexPath:nil];
            break;
        case TopViewTypeForDeviceInfoView:
            // 显示设备信息界面 -- 拖动的时候,不一定选中了.没选中就不需要显示
            if (self.deviceInfoBackgroundView.hidden && (self.selectedDevice/* || self.selectedDeviceType*/)) {
                [self.deviceInfoBackgroundView setHidden:NO animated:YES];
            }
            // 隐藏操作界面
            if (self.operatioinView.hidden == NO) {
                [self.operatioinView setHidden:YES animated:YES];
            }
            // 隐藏流程界面
            if (self.processBackgroundView.hidden == NO) {
                [self.processBackgroundView setHidden:YES animated:YES];
            }
            break;
        case TopViewTypeForCommonDeviceView:
            if (self.showQuickChooseButton.hidden == NO) {
                [self.showQuickChooseButton setHidden:YES animated:YES completionHandle:^{
                    if (weakSelf.commonDeviceBackgroundView.hidden) {
                        [weakSelf.commonDeviceBackgroundView setHidden:NO animated:YES];
                    }
                }];
            } else {
                if (self.commonDeviceBackgroundView.hidden) {
                    [self.commonDeviceBackgroundView setHidden:NO animated:YES];
                    // 出现的时候默认为公共设备
                    self.selectedOtherViewType = OtherViewTypeCommonDevice;
                }
            }
            
            
            
            // 隐藏操作界面
            if (self.operatioinView.hidden == NO) {
                [self.operatioinView setHidden:YES animated:YES];
            }
            // 隐藏流程界面
            if (self.processBackgroundView.hidden == NO) {
                [self.processBackgroundView setHidden:YES animated:YES];
            }
            break;
        case TopViewTypeForProcessView:
            // 隐藏操作界面
            if (self.operatioinView.hidden == NO) {
                [self.operatioinView setHidden:YES animated:YES];
            }
            if (self.showQuickChooseButton.hidden == NO) {
                [self.showQuickChooseButton setHidden:YES animated:YES];
            }
            // 显示流程界面
            if (self.processBackgroundView.hidden) {
                [self.processBackgroundView setHidden:NO animated:YES];
            }
            break;
    }
}


#pragma mark 更新设备详情界面的值
- (void)updateUIOfDeviceInfoView
{
    if (!self.selectedDevice) {
        return ;
    }
    NSString *deviceType = self.selectedDevice.UEQP_Type;
    NSString *value = self.selectedDevice.value;
    NSString *deviceInfoNibName;
    NSArray *cmdArray = kDeviceTypeInfo(deviceType)[@"controlCMD"];
    /**
     *   根据支持的命令种类 或 类型决定加载的nib文件
     */
    if ([deviceType isEqualToString:@"麦克"]) {
        deviceInfoNibName = @"DeviceInfoMicView";
    } else if ([deviceType isEqualToString:@"摄像头"]) { // ORIENTATION
        deviceInfoNibName = @"DeviceInfoCameraView";
    } else if ([deviceType isEqualToString:@"电视"]) { // OC SLIDER CHANNEL
        deviceInfoNibName = @"DeviceInfoOCSliderChannelView";
    } else if ([cmdArray containsObject:@"oc"] && [cmdArray containsObject:@"slider"]) { // OC SLIDER
        deviceInfoNibName = @"DeviceInfoOCSliderView";
    } else if ([cmdArray containsObject:@"oc"]) { // OC
        deviceInfoNibName = @"DeviceInfoOCView";
    } else if ([cmdArray containsObject:@"slider"]) { // SLIDER
        deviceInfoNibName = @"DeviceInfoSliderView";
    }
    
   
    
    if (_deviceInfoView && ![_deviceInfoView.nibName isEqualToString:deviceInfoNibName]) { // 之前的设备信息界面不一样
        [self.deviceInfoView removeFromSuperview];
        self.deviceInfoView = nil;
    }
    
    if (!_deviceInfoView) { // 为空.则初始化
        self.deviceInfoView = [[DeviceInfoBaseView alloc] initWithNibName:deviceInfoNibName];
        _deviceInfoView.delegate = self;
        _deviceInfoView.translatesAutoresizingMaskIntoConstraints = NO;
        [_deviceInfoBackgroundView addSubview:_deviceInfoView];

        // 设置约束
        [_deviceInfoView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_deviceInfoView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_deviceInfoView autoConstrainAttribute:ALDimensionWidth toAttribute:NSLayoutAttributeWidth ofView:_deviceInfoBackgroundView];
        [_deviceInfoView autoConstrainAttribute:ALDimensionHeight toAttribute:ALDimensionHeight ofView:_deviceInfoBackgroundView];
        if ([deviceType isEqualToString: @"电视"]) {
            _deviceInfoView.channelArray = self.channelArray;
            _deviceInfoView.selectedChannel = 0;
        }
    }
    
    
    // 当前版本已 取消批量 功能
    // 根据是否批量操作,改变控件的enabled
    _deviceInfoView.isBatch = FALSE;
    
    // 更新值
    if (self.selectedDevice) {
        // 摄像头
        if ([deviceType isEqualToString:@"摄像头"]) {
            self.deviceInfoView.isSelected = self.selectedDevice.needFollow;
        }
        
        // 电视
        if ([deviceType isEqualToString:@"电视"]) {
            _deviceInfoView.selectedChannel = [self.channelArray indexOfObject:self.selectedDevice.channel];
        }
        
        self.deviceInfoView.deviceInfoImageView.image = [UIImage imageNamed:[self.selectedDevice imageNameByStatusRunAnimationOnImageView:self.deviceInfoView.deviceInfoImageView]];
        self.deviceInfoView.deviceInfoNameLabel.text = self.selectedDevice.UEQP_Name;
        if (self.selectedDevice.deviceOCState == DeviceClose) {
            [self.deviceInfoView.deviceInfoOpenButton setSelected:NO];
            [self.deviceInfoView.deviceInfoCloseButton setSelected:YES];
        } else if (self.selectedDevice.deviceOCState == DeviceOpen){
            [self.deviceInfoView.deviceInfoOpenButton setSelected:YES];
            [self.deviceInfoView.deviceInfoCloseButton setSelected:NO];
        } else {
            [self.deviceInfoView.deviceInfoCloseButton setSelected:NO];
            [self.deviceInfoView.deviceInfoOpenButton setSelected:NO];
        }
        NSString *cameraFollowText = nil;
        if (self.selectedDevice.followUEQP_ID) {
            cameraFollowText = [[Common shareCommon] getDeviceWithUEQP_ID:self.selectedDevice.followUEQP_ID].UEQP_Name;
        } else {
            cameraFollowText = kHintForCameraFollow;
        }
        [self.deviceInfoView.cameraFollowConfigButton setTitle:cameraFollowText forState:UIControlStateNormal];
        
    } /*else {
        if (self.deviceInfoView.deviceInfoImageView.isAnimating) {// 正在动画,就停止 -- 之前选中过该类型下的某个连接打开的设备
            [self.deviceInfoView.deviceInfoImageView stopAnimating];
        }
        self.deviceInfoView.deviceInfoImageView.image = [UIImage imageNamed:kDeviceTypeInfo(self.selectedDeviceType)[@"imageName"]];
        self.deviceInfoView.deviceInfoNameLabel.text = @"批量操作";
        [self.deviceInfoView.deviceInfoCloseButton setSelected:NO];
        [self.deviceInfoView.deviceInfoOpenButton setSelected:NO];
    }*/
    
    
    // 换算slider中的大小(0 - 1)
    if ([kDeviceTypeInfo(deviceType)[@"controlCMD"] containsObject:@"slider"]) { // 有音量键
        CGFloat maxValue = [kDeviceTypeInfo(deviceType)[@"maxValue"] floatValue];
        CGFloat minValue = [kDeviceTypeInfo(deviceType)[@"minValue"] floatValue];
        if (value) { // 选中单个设备
            self.deviceInfoView.volumeSlider.value = ([value floatValue] - minValue) / (maxValue - minValue);
        } else { // 选中多个设备
            self.deviceInfoView.volumeSlider.value = 0;
        }
    }
    
}


#pragma mark 显示详情页 -
- (void)showDeviceInfoByIsBatch:(BOOL)isBatch
{
    [self updateUIOfDeviceInfoView];
    
    
    
    [self updateViewHideOrShowByType:TopViewTypeForDeviceInfoView];
}

#pragma mark - 图片点击切换操作状态
- (void)actualImageViewTapGRAction:(UITapGestureRecognizer *)sender
{
    // 正常模式时，点击底图出现视角切换
    if (self.currentMode == ActualModeTypeNormal) {
        [self startTimerForAutoHideViewpointButtonsView];// 几秒后自动隐藏
    }
    
    [self updateViewHideOrShowByType:TopViewTypeNone];
    
}

#pragma mark - 根据AUTOID获取设备的布局模型
- (DetaiLayoutOfAreaByViewpointType *)getDetailOfAreaScreenWithAutoID:(NSInteger)autoID
{
    for (DetaiLayoutOfAreaByViewpointType *model in self.detailLayoutOfAreaByViewpointTypeArray) {
        if (model.device.AutoID == autoID) {
            return model;
        }
    }
    return nil;
}

#pragma mark - 根据输入源,返回允许连接的所有输出源的布局模型
- (NSArray *)getDetailOfAreaScreenOfAllowConnectedOutDevicesWithInDeviceType:(NSString *)inDeviceType
{
    if ([kDeviceTypeInfo(inDeviceType)[@"inOrOut"] isEqualToString:@"out"]) {
        return nil;
    }
    NSMutableArray *detailOfAreaScreenOfCanConnDevices = [NSMutableArray array];
    NSArray *allowConnectedOutDevicesArray = [kDeviceTypeInfo(inDeviceType)[@"soundConnectedType"] arrayByAddingObjectsFromArray:kDeviceTypeInfo(inDeviceType)[@"videoConnectedType"]];
    // 输出源
    for (DetaiLayoutOfAreaByViewpointType *model in self.detailLayoutOfAreaByViewpointTypeArray) {
        if ([allowConnectedOutDevicesArray containsObject:model.device.UEQP_Type]) {// 包含该key
            [detailOfAreaScreenOfCanConnDevices addObject:model];
        }
    }
    return detailOfAreaScreenOfCanConnDevices;
}

#pragma mark - 设置数组中所有布局模型对应的followView的StateImageView图片
- (void)changeFollowViewImageWithStatus:(DeviceViewImageStatus)status inArray:(NSArray *)array
{
    for (DetaiLayoutOfAreaByViewpointType *model in array) {
        WFFFollowHandsView *deviceView = (WFFFollowHandsView *)[self.contentView viewWithTag:model.device.AutoID];
        if ([deviceView isKindOfClass:[WFFFollowHandsView class]]) {
            // 获取当前view的imageview
            UIImageView *imageView = (UIImageView *)[deviceView viewWithTag:kTagForImageViewInWFFFollowHandsView];

            // 设置当前状态应展示的image
            NSString *imageName = [NSString stringWithFormat:@"state_%d", status];
            
            imageView.image = [UIImage imageNamed:imageName];
            // 根据状态,调整大小
            if (status != DeviceViewImageStatusForShouldConn) { // 普通大小
                deviceView.transform = CGAffineTransformIdentity;
            } else {
                deviceView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }
            imageView.frame = deviceView.bounds;
        } else {
            kLog(@"设备与非设备视图存在 重复的tag: %ld, %@", (long)model.device.AutoID, model.device);
        }
        
    }
}

#pragma mark - 根据FollowView的当前位置,判断是否在某个可连接设备上,若在返回该设备的布局模型
- (DetaiLayoutOfAreaByViewpointType *)getDetailLayoutOfDeviceWhichShouldConnByDeviceType:(NSString *)deviceType point:(CGPoint)currentPoint;
{
    
    NSArray *canConnDevices = [self getDetailOfAreaScreenOfAllowConnectedOutDevicesWithInDeviceType:deviceType];
    DetaiLayoutOfAreaByViewpointType *conn = nil;
    for (DetaiLayoutOfAreaByViewpointType *deviceDetailOfAreaScren in canConnDevices) {
        CGRect rect = CGRectMake(deviceDetailOfAreaScren.origin_X, deviceDetailOfAreaScren.origin_Y, deviceDetailOfAreaScren.size_Width, deviceDetailOfAreaScren.size_Height);
        if (CGRectContainsPoint(rect, currentPoint)) {
            conn = deviceDetailOfAreaScren;
            break;
        }
    }
    
    return conn;
}

/**
 *  根据ID获取其他设备
 *
 *  @param autoID ID
 *
 *  @return 其他设备,nil说明ID对应的设备是实体设备（非公共设备或音频文件）
 */
- (DeviceForUser *)otherDevicesIsContainDeviceByAutoID:(NSInteger)autoID
{
    NSArray *otherDeviceArray = self.selectedOtherViewType == OtherViewTypeCommonDevice ? kCommonDevices : kMusicFile;
    for (DeviceForUser *model in otherDeviceArray) {
        if (model.AutoID == autoID) {
            return model;
        }
    }
    return nil;
}


#pragma mark - WFFFollowHandsViewDelegate
#pragma mark 这里的移动的代理方法,专门处理连接操作 --- 只有正常模式才有用
- (void)followHandsView:(WFFFollowHandsView *)followHandsView beginMoveWithHandsPointInSuperView:(CGPoint)handsPointInSuperView
{
    if (self.currentMode == ActualModeChangeScreen) {
        [self followHandsView:followHandsView doMoveForChangeLayoutWithPoint:handsPointInSuperView isEnd:NO];
        return;
    }
    if (self.currentMode != ActualModeTypeNormal) {
        return;
    }
    
    
    // 吧移动的设备 置于最前面;
    [followHandsView.superview bringSubviewToFront:followHandsView];
    // 放入移动设备字典中
    [self.movingViewDict setObject:followHandsView forKey:@(followHandsView.tag)];
    
    DeviceForUser *commonDevice = [self otherDevicesIsContainDeviceByAutoID:followHandsView.tag];
    NSString *deviceType = nil;
    if (commonDevice) { // 当前拖动的是公共设备
        deviceType = commonDevice.UEQP_Type;
        
    } else {
        DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];
        
        deviceType = model.device.UEQP_Type;
    }
    
    NSArray *canConnDevices = [self getDetailOfAreaScreenOfAllowConnectedOutDevicesWithInDeviceType:deviceType];
    // 设置允许连接的设备图片
    [self changeFollowViewImageWithStatus:DeviceViewImageStatusForAllowConn inArray:canConnDevices];
}



- (void)followHandsView:(WFFFollowHandsView *)followHandsView movingWithHandsPointInSuperView:(CGPoint)handsPointInSuperView
{
    
    if (self.currentMode == ActualModeChangeScreen) {
        [self followHandsView:followHandsView doMoveForChangeLayoutWithPoint:handsPointInSuperView isEnd:NO];
        return;
    }
    if (self.currentMode != ActualModeTypeNormal) {
        [followHandsView endMoveByGR:[followHandsView panGR]];
        return;
    }
    

    DeviceForUser *commonDevice = [self otherDevicesIsContainDeviceByAutoID:followHandsView.tag];
    NSString *deviceType = nil;
    if (commonDevice) { // 当前拖动的是公共设备
        deviceType = commonDevice.UEQP_Type;
    } else {
        DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];
        
        deviceType = model.device.UEQP_Type;
    }
    
    /**
     *  之前移动过高亮的设备 重新变为高亮
     */
    // 移动过程中,所有可连接设置为高亮
    NSArray *canConnDevices = [self getDetailOfAreaScreenOfAllowConnectedOutDevicesWithInDeviceType:deviceType];
    // 设置允许连接的设备图片
    [self changeFollowViewImageWithStatus:DeviceViewImageStatusForAllowConn inArray:canConnDevices];
    
    
    // 获取放下即可连接的设备
    DetaiLayoutOfAreaByViewpointType *conn = [self getDetailLayoutOfDeviceWhichShouldConnByDeviceType:deviceType point:followHandsView.center];
    // 存在则变为放大高亮
    if (conn) { //
        [self changeFollowViewImageWithStatus:DeviceViewImageStatusForShouldConn inArray:@[conn]];
    }
}


- (void)followHandsView:(WFFFollowHandsView *)followHandsView endMoveWithHandsPointInSuperView:(CGPoint)handsPointInSuperView
{
    
    if (self.currentMode == ActualModeChangeScreen) {
        [self followHandsView:followHandsView doMoveForChangeLayoutWithPoint:handsPointInSuperView isEnd:YES];
        return;
    }
    
    
    [self.movingViewDict removeObjectForKey:@(followHandsView.tag)];
    
    
    DeviceForUser *commonDevice = [self otherDevicesIsContainDeviceByAutoID:followHandsView.tag];

    
    DeviceForUser *device = nil;
    if (commonDevice) { // 当前拖动的是公共设备
        device = commonDevice;
        
    } else {
        DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];
        
        device = model.device;
        
        if (self.currentMode != ActualModeTypeNormal) {
            // 最终view肯定要回到原来位置
            [UIView animateWithDuration:0.3 animations:^{
                [self changeFollowViewImageWithStatus:DeviceViewImageStatusForNormal inArray:self.detailLayoutOfAreaByViewpointTypeArray];
                followHandsView.frame = CGRectMake(model.origin_X, model.origin_Y, model.size_Width, model.size_Height);
            } completion:^(BOOL finished) {
                
                
            }];
            return;
        }
    }
    
    
    
    
    BOOL flag = NO;// 标志是否放到可连接设备
    
//    if (!model) {
//        kLog(@"设备模型和布局模型不匹配!请重新启动!");
//    } else {
    
        DetaiLayoutOfAreaByViewpointType *conn = [self getDetailLayoutOfDeviceWhichShouldConnByDeviceType:device.UEQP_Type point:followHandsView.center];
        
        if (conn && [self checkPermissionsByDevice:device]) { // 放到正确的输出源上.判断是否有权限
            DeviceForUser *outDevice = conn.device;
            flag = YES;
            kDeviceConn(device, outDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
                if (isSuccess) {
                    kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 与  操作设备类型:%@ 设备ID:%@ 连接%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, kDeviceTypeInfo(otherDeviceForUser.UEQP_Type)[@"name"], otherDeviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
                } else {
//                    [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
                }
                
            });
        }
//    }
    
    [self changeFollowViewImageWithStatus:DeviceViewImageStatusForNormal inArray:self.detailLayoutOfAreaByViewpointTypeArray];
    // 选中的高亮
    if (_selectedDevice) {
        [self changeFollowViewImageWithStatus:DeviceViewImageStatusForHighlight inArray:@[[self getDetailOfAreaScreenWithAutoID:_selectedDevice.AutoID]]];
    }
    
    
    if (flag) {
        if (commonDevice) {
            // view先缩小消失,最后显示在原来位置
            [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.1 animations:^{
                    followHandsView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }];
                [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.4 animations:^{
                    followHandsView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                }];
            } completion:^(BOOL finished) {
                [followHandsView removeFromSuperview];
            }];
        } else {
            DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];
            
            // view先缩小消失,最后显示在原来位置
            [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.1 animations:^{
                    followHandsView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }];
                [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.4 animations:^{
                    followHandsView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                }];
            } completion:^(BOOL finished) {
                followHandsView.transform = CGAffineTransformIdentity;
                followHandsView.frame = CGRectMake(model.origin_X, model.origin_Y, model.size_Width, model.size_Height);
                
            }];
        }
    } else {
        if (commonDevice) {
            [followHandsView removeFromSuperview];
        } else {
            DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];

            // 最终view肯定要回到原来位置
            [UIView animateWithDuration:0.3 animations:^{
                followHandsView.frame = CGRectMake(model.origin_X, model.origin_Y, model.size_Width, model.size_Height);
            } completion:^(BOOL finished) {
                
                
            }];
        }
    }
    
}

- (void)followHandsView:(WFFFollowHandsView *)followHandsView cancelMoveWithHandsPointInSuperView:(CGPoint)handsPointInSuperView
{
    if (self.currentMode == ActualModeChangeScreen) {
        [self followHandsView:followHandsView doMoveForChangeLayoutWithPoint:handsPointInSuperView isEnd:YES];
        return;
    }
    
    
    [self.movingViewDict removeObjectForKey:@(followHandsView.tag)];
    
    DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];
    
    if (self.currentMode != ActualModeTypeNormal) {
        [self changeFollowViewImageWithStatus:DeviceViewImageStatusForNormal inArray:self.detailLayoutOfAreaByViewpointTypeArray];
        // 选中的高亮
        if (_selectedDevice) {
            [self changeFollowViewImageWithStatus:DeviceViewImageStatusForHighlight inArray:@[[self getDetailOfAreaScreenWithAutoID:_selectedDevice.AutoID]]];
        }

        // 最终view肯定要回到原来位置
        [UIView animateWithDuration:0.3 animations:^{
                    } completion:^(BOOL finished) {
            
            followHandsView.frame = CGRectMake(model.origin_X, model.origin_Y, model.size_Width, model.size_Height);
        }];
        return;
    }
}





#pragma mark 点击选中设备
- (void)clickFollowHandsView:(WFFFollowHandsView *)followHandsView
{
    
    self.selectedDevice = [[Common shareCommon] getActualDeviceWithID:followHandsView.tag];
    
    kLog(@"所查看的设备ID:%ld %@", (long)self.selectedDevice.AutoID,  kDeviceTypeInfo(self.selectedDevice.UEQP_Type)[@"name"]);
}

#pragma mark - [场景配置时的CollectionView]长按设备 悬浮 可移动.
- (void)deviceImageViewLongPressGRAction:(UILongPressGestureRecognizer *)sender
{
    NSIndexPath *indexPath = nil;
    DeviceCollectionViewCell *cell = nil;
    DeviceForUser *model = nil;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            // 刚触摸的时候才赋值,移动过程中进来后,indexPath对应的cell已经删除,若再执行下面语句就会溢出
            cell = (DeviceCollectionViewCell *)sender.view;
            indexPath = [self.deviceCollectionView indexPathForCell:cell];
            model = self.devicesArray[indexPath.row];
            
            // 显示跟随的view
            self.currentHandsView = [WFFFollowHandsView followHandsViewWithWidth:kFollowHandsViewOfDeviceWidth height:kFollowHandsViewOfDeviceHeight deviceCell:cell device:model onView:self.contentView];
            // 删除cell,隐藏collectionview
            [self deleteDeviceCollectionViewCellWithIndexPath:indexPath];
            // 隐藏设备列表
            [self showShadeView:NO];
            // 开始移动
            [self.currentHandsView beginMoveByGR:sender];
            //            kLog(@"UIGestureRecognizerStateBegan");
            break;
        case UIGestureRecognizerStateChanged:
            [self.currentHandsView moveByGR:sender];
            //            kLog(@"UIGestureRecognizerStateChanged");
            break;
        case UIGestureRecognizerStatePossible:
            
            //            kLog(@"UIGestureRecognizerStatePossible");
            break;
        default: // UIGestureRecognizerStateEnded UIGestureRecognizerStateFailed UIGestureRecognizerStateCancelled
            [self.currentHandsView endMoveByGR:sender];
            [self showShadeView:YES];
            break;
    }
}

#pragma mark - 公共设备长按 - 可拖动
- (void)otherDeviceImageViewLongPressGRAction:(UILongPressGestureRecognizer *)sender
{
    NSIndexPath *indexPath = nil;
    DeviceCollectionViewCell *cell = nil;
    DeviceForUser *model = nil;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            // 刚触摸的时候才赋值,移动过程中进来后,indexPath对应的cell已经删除,若再执行下面语句就会溢出
            cell = (DeviceCollectionViewCell *)sender.view;
            indexPath = [self.commonDeviceCollectionView indexPathForCell:cell];
            if (self.selectedOtherViewType == OtherViewTypeCommonDevice) {
                model = kCommonDevices[indexPath.row];
            } else {
                model = kMusicFile[indexPath.row];
            }
            
            
            // 显示跟随的view
            self.currentHandsView = [WFFFollowHandsView followHandsViewWithWidth:kFollowHandsViewOfDeviceWidth height:kFollowHandsViewOfDeviceHeight deviceCell:cell device:model onView:self.contentView];
            self.currentHandsView.delegate = self;
//            // 删除cell,隐藏collectionview
//            [self deleteCellWithIndexPath:indexPath];
            // 隐藏公共设备列表
            [self.commonDeviceBackgroundView setHidden:YES animated:NO];
            // 开始移动 - 执行代理
            [self.currentHandsView beginMoveByGR:sender];
            //            kLog(@"UIGestureRecognizerStateBegan");
            break;
        case UIGestureRecognizerStateChanged:
            [self.currentHandsView moveByGR:sender];
            //            kLog(@"UIGestureRecognizerStateChanged");
            break;
        case UIGestureRecognizerStatePossible:
            
            //            kLog(@"UIGestureRecognizerStatePossible");
            break;
        default: // UIGestureRecognizerStateEnded UIGestureRecognizerStateFailed UIGestureRecognizerStateCancelled
            [self.currentHandsView endMoveByGR:sender];
            // 显示公共设备列表
            [self.commonDeviceBackgroundView setHidden:NO animated:NO];
            // 代理中,动画结束会从父视图中移除
//            [self.currentHandsView removeFromSuperview];
            self.currentHandsView = nil;
            break;
    }
}
//#pragma mark 长按批量选中
//- (void)longPressFollowHandsView:(WFFFollowHandsView *)followHandsView gr:(UILongPressGestureRecognizer *)gr
//{
//    if (self.currentMode != ActualModeTypeNormal) {
//        return;
//    }
//    
//    DetaiLayoutOfAreaByViewpointType *model = [self getDetailOfAreaScreenWithAutoID:followHandsView.tag];
//    
//    
//    // 长按后,不再允许接收移动手势
//    switch (gr.state) {
//        case UIGestureRecognizerStateBegan:
//            // 显示详情页,选中同类型设备
//            [self setDeviceViewGREnable:NO withType:@"move"];
//            self.selectedDeviceType = model.device.UEQP_Type;
//            break;
//        case UIGestureRecognizerStateChanged:
////
//            break;
////        case UIGestureRecognizerStatePossible:
////            
////            break;
//        default: // UIGestureRecognizerStateEnded UIGestureRecognizerStateFailed UIGestureRecognizerStateCancelled
//            [self setDeviceViewGREnable:YES withType:@"move"];
//            break;
//    }
//    
//}



#pragma mark - 更改布局模式中,设备View停止移动后调用 -- 主要处理与垃圾篓的关系,以及垃圾篓的图标是否改变
- (void)followHandsView:(WFFFollowHandsView *)followHandsView doMoveForChangeLayoutWithPoint:(CGPoint)handsPointInSuperView isEnd:(BOOL)isEnd
{
    // 转换坐标点: followView的父视图->垃圾篓的父视图
    CGPoint handsPoint = [self.view convertPoint:handsPointInSuperView fromView:followHandsView.superview];
    if (CGRectContainsPoint(self.trashImageView.frame, handsPoint)) {
        if (isEnd) {
            // 移动结束,在垃圾篓内,删除
            [followHandsView removeFromSuperview];
            self.trashImageView.transform = CGAffineTransformIdentity;
            
            [self.trashImageView setHighlighted:NO];
            
        } else {
            
            self.trashImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            [self.trashImageView setHighlighted:YES];
        }
    } else {
        self.trashImageView.transform = CGAffineTransformIdentity;
        
        [self.trashImageView setHighlighted:NO];
    }
}

#pragma mark - 检查当前实体设备数量和保存的实体设备布局 是否一一对应 (防止PC端更改设备配置)
/*
 1.删除本地存储的布局配置中,多余的ID(后台删除了某ID)
 2.将可用的布局取出来,布局到界面上
 3.将未布局的设备存入devicesArray [为nil时,说明没有]
 */
- (void)checkDevices
{
    self.detailLayoutOfAreaByViewpointTypeArray = [[DBHelper shareDBHelper] getDeviceLayoutWithViewpointType:self.currentViewpointType];
    BOOL hasChanged = NO;
    // 先删除多余的 [不影响最终的YES or NO, 即如果只有多余的.删除后仍然为可用布局]
    for (DetaiLayoutOfAreaByViewpointType *layoutModel in self.detailLayoutOfAreaByViewpointTypeArray) {
        BOOL flag = NO;
        for (DeviceForUser *deviceModel in kCurrentActualDeviceArray) {
            if ([deviceModel.UEQP_ID isEqualToString:layoutModel.deviceID]) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            hasChanged = YES;
            [[DBHelper shareDBHelper] deleteDetailLayoutItemWithViewpointType:self.currentViewpointType deviceID:layoutModel.deviceID];
        }
    }
    
    if (hasChanged) {
        // 更新
        self.detailLayoutOfAreaByViewpointTypeArray = [[DBHelper shareDBHelper] getDeviceLayoutWithViewpointType:self.currentViewpointType];
    }
   
    // 未布局的设备
    self.devicesArray = [NSMutableArray arrayWithArray:kCurrentActualDeviceArray];
    // 设备数量一直,判断是否所有设备都相同
    for (DeviceForUser *deviceModel in kCurrentActualDeviceArray) {
        NSString *deviceID = deviceModel.UEQP_ID;
        BOOL flag = NO;
        // 查找相同ID
        for (DetaiLayoutOfAreaByViewpointType *layoutModel in self.detailLayoutOfAreaByViewpointTypeArray) {
            if ([deviceID isEqualToString:layoutModel.deviceID] ) {
                flag = YES;
                break;
            }
        }
        // flag为YES说明该设备在该视角中已经配置.从未布局的数组中移除
        if (flag) {
            [self.devicesArray removeObject:deviceModel];
        }
    }
    
    // 有部分ID已有布局,直接配置
    if ([self.detailLayoutOfAreaByViewpointTypeArray count] > 0) {
        [self layoutDeviceByDB];
    }
    
}

//#pragma mark - 将当前页面所有设备进行随机布局
//- (void)layoutForRandom
//{
//    // 遍历collectionView.模拟全部cell放入contentView中
//    // [★ 若直接从devicesarray中取出来插入数据库的话,假如用户操作一半之后(每次配置号一个设备,就会从devicesarray中移除),才选择随机,那么之前操作的不会保存]
//    // 只有模拟放入contentView中,再调用save方法.才是最可靠的操作.
//    for (DeviceForUser *device in self.devicesArray) {
//        // 随机生成
//       [WFFFollowHandsView followHandsViewByRandomPositionWithWidth:kFollowHandsViewOfDeviceWidth height:kFollowHandsViewOfDeviceHeight device:device onView:self.contentView];
//    }
//    self.devicesArray = nil;
//    [self okButtonActionForAddScreen:nil];
//}
#pragma mark - 将当前页面所有未布局的设备按顺序进行布局
- (void)layoutInOrder
{
    // 遍历collectionView.模拟全部cell放入contentView中
    // [★ 若直接从devicesarray中取出来插入数据库的话,假如用户操作一半之后(每次配置号一个设备,就会从devicesarray中移除),才选择随机,那么之前操作的不会保存]
    // 只有模拟放入contentView中,再调用save方法.才是最可靠的操作.
    for (NSInteger i = 0; i < self.devicesArray.count; i++) {
        DeviceForUser *device = self.devicesArray[i];
        // 按顺序生成
        [WFFFollowHandsView followHandsViewByOrderWithWidth:kFollowHandsViewOfDeviceWidth height:kFollowHandsViewOfDeviceHeight device:device onView:self.contentView num:i];
    }
    self.devicesArray = nil;
    [self okButtonActionForAddScreen:nil];
}
#pragma mark - 将当前页面所有设备的布局全部保存
- (void)saveDeviceLayout
{
    
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[WFFFollowHandsView class]]) {
            DeviceForUser *device = [[Common shareCommon] getActualDeviceWithID:view.tag];
            DetaiLayoutOfAreaByViewpointType *model = [DetaiLayoutOfAreaByViewpointType new];
            model.areaID = kCurrentArea.AreaID;
            model.viewpointType = self.currentViewpointType;
            model.deviceID = device.UEQP_ID;
            model.origin_X = view.frame.origin.x;
            model.origin_Y = view.frame.origin.y;
            model.size_Width = view.frame.size.width;
            model.size_Height = view.frame.size.height;
            [array addObject:model];
        }
    }
    
    // 将布局保存
    if ([[DBHelper shareDBHelper] setDeviceLayoutWithViewpointType:self.currentViewpointType layouts:array]) {
        kLog(@"布局保存成功");
    } else {
        kLog(@"布局保存失败");
    }
}

#pragma mark 删除指定cell
- (void)deleteDeviceCollectionViewCellWithIndexPath:(NSIndexPath *)indexPath
{
    [self.devicesArray removeObjectAtIndex:indexPath.row];
    [self.deviceCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - 根据设备布局数据 布局界面(布局结束后,每个控件都已经绑定了设备信息)
- (void)layoutDeviceByDB
{
    // 根据保存的数据 布局
    for (int i = 0; i < self.detailLayoutOfAreaByViewpointTypeArray.count; i++) {
        DetaiLayoutOfAreaByViewpointType *model = self.detailLayoutOfAreaByViewpointTypeArray[i];
        // 将布局模型和设备信息模型绑定
        model.device = [[Common shareCommon] getDeviceWithUEQP_ID:model.deviceID];
        
        WFFFollowHandsView *deviceView = [[WFFFollowHandsView alloc] initWithFrame:CGRectMake(model.origin_X, model.origin_Y, model.size_Width, model.size_Height)];
        deviceView.tag = model.device.AutoID;
        
        
        // 选中状态
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"state_%d",0]]];
        imageView.frame = deviceView.bounds;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.tag = kTagForImageViewInWFFFollowHandsView;
        [deviceView addSubview:imageView];
        
        // 设备图标
        UIImageView *deviceImage = [UIImageView new];
        deviceImage.image = [UIImage imageNamed:[model.device imageNameByStatusRunAnimationOnImageView:deviceImage]];
//        UIImageView *deviceImage = [[UIImageView alloc] initWithImage:]];
        deviceImage.frame = deviceView.bounds;
        deviceImage.tag = kTagForDeviceImageInWFFFollowHandsView;
        [deviceView addSubview:deviceImage];
        
        // 设置不能移动
        deviceView.canMove = NO;
        // 单机出现设备信息
        deviceView.canClick = YES;
        // 长按进入更改布局状态(长按后关闭长按手势)
        deviceView.canLongPress = YES;
        deviceView.delegate = self;
        [self.contentView addSubview:deviceView];
    }
}

#pragma mark - 设置当前页面的所有设备view的 不同手势的开关
- (void)setDeviceViewGREnable:(BOOL)enable withType:(NSString *)grType
{
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[WFFFollowHandsView class]]) {
            if ([grType isEqualToString:@"move"]) {
                ((WFFFollowHandsView *)view).canMove = enable;
            } else if ([grType isEqualToString:@"longPress"]){
                ((WFFFollowHandsView *)view).canLongPress = enable;
            } else {
                ((WFFFollowHandsView *)view).canClick = enable;
            }
        }
    }
}


#pragma mark - UICollectionViewDelegate && UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (collectionView == self.deviceCollectionView) {
        count = self.devicesArray.count;
    }
    if (collectionView == self.commonDeviceCollectionView) {
        if (self.selectedOtherViewType == OtherViewTypeCommonDevice) {
            count = kCommonDevices.count;
        } else if (self.selectedOtherViewType == OtherViewTypeMusicFile){
            count = kMusicFile.count;
        }
    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.deviceCollectionView) {
        DeviceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deviceCell" forIndexPath:indexPath];
        DeviceForUser *model = self.devicesArray[indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        cell.infoLabel.text = model.UEQP_Name;
        cell.imageView.image = [UIImage imageNamed:@"state_0"];
        cell.deviceImageView.image = [UIImage imageNamed:[model imageNameByStatusRunAnimationOnImageView:cell.deviceImageView]];
        
        cell.tag = indexPath.row;

        if (cell.gestureRecognizers.count == 0) {
            // 手势事件中,根据view的tag来决定选中的哪一个设备.
            [cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deviceImageViewLongPressGRAction:)]];
        }
        return cell;
    }
    
    if (collectionView == self.commonDeviceCollectionView) {
        DeviceForUser *model = nil;
        if (self.selectedOtherViewType == OtherViewTypeCommonDevice) {
            model = kCommonDevices[indexPath.row];
        } else {
            model = kMusicFile[indexPath.row];
        }
        
        [collectionView invalidateIntrinsicContentSize];
        DeviceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commonDeviceCell" forIndexPath:indexPath];
        cell.infoLabel.text = model.UEQP_Name;
        cell.imageView.image = [UIImage imageNamed:@"state_0"];
//        NSString *imageName = [model imageName];
//        cell.deviceImageView.image = [UIImage imageNamed:imageName];
        cell.deviceImageView.image = [UIImage imageNamed:[model imageNameByStatusRunAnimationOnImageView:cell.deviceImageView]];
        [cell.imageView setHighlightedImage:[UIImage imageNamed:[NSString stringWithFormat:@"state_%d", DeviceViewImageStatusForHighlight]]];
        
        cell.tag = indexPath.row;
        
//        cell.imageView.userInteractionEnabled = YES;
        if (cell.gestureRecognizers.count == 0) {
            // 手势事件中,根据view的tag来决定选中的哪一个设备.
            [cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(otherDeviceImageViewLongPressGRAction:)]];
        }
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    if (collectionView == self.commonDeviceCollectionView) {
        if (self.selectedOtherViewType == OtherViewTypeCommonDevice) {
            self.selectedDevice = kCommonDevices[indexPath.row];
        } else {
            self.selectedDevice = kMusicFile[indexPath.row];
        }
        
    }
    return;
}
// 将快速选择的collectionView中indexPath对应的cell设置为highlight,其他设置不高亮
- (void)setCellHighlightWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    for (DeviceCollectionViewCell *cell  in collectionView.visibleCells) {
        NSIndexPath *cellIndexPath = [collectionView indexPathForCell:cell];
        // indexPath == nil 时, row = 0, section = 0
        if (indexPath && cellIndexPath.row == indexPath.row && cellIndexPath.section == indexPath.section) {
            [cell.imageView setHighlighted:YES];
        } else {
            [cell.imageView setHighlighted:NO];
        }
    }
}

#pragma mark - 显示创建场景的shadeView
- (void)showShadeView:(BOOL)isShow
{
    [self.screenConfigShadeView setHidden:!isShow animated:YES];
}

#pragma mark - setter
#pragma mark - 选中设备, 显示详细信息
- (void)setSelectedDevice:(DeviceForUser *)selectedDevice
{
    if (_selectedDevice != selectedDevice) {
        
        if (_selectedDevice) {
            self.lastSelectedDevice = _selectedDevice;
            // 原本选中设备的布局模型 -- 如果是其他设备,则为空
            DetaiLayoutOfAreaByViewpointType *oldSelectedDeviceDetailLayout = [self getDetailOfAreaScreenWithAutoID:_selectedDevice.AutoID];
            // 修改界面的选中状态
            if (oldSelectedDeviceDetailLayout) {
                 [self changeFollowViewImageWithStatus:DeviceViewImageStatusForNormal inArray:@[oldSelectedDeviceDetailLayout]];
            } else { // 原本的为其他视图中的设备
                [self setCellHighlightWithCollectionView:self.commonDeviceCollectionView indexPath:nil];
            }
        }
        
        
        [self.cameraFollowConfigView setHidden:YES animated:YES];
        self.deviceInfoView.cameraFollowConfigButton.selected = NO;
        
        _selectedDevice = nil;
        _selectedDevice = selectedDevice;
        
        if (!selectedDevice) {
            return;
        }
//        // 选中设备,则不选中类型
//        self.selectedDeviceType = nil;
        
        // 选中设备的布局模型
        DetaiLayoutOfAreaByViewpointType *selectedDeviceDetailLayout = [self getDetailOfAreaScreenWithAutoID:_selectedDevice.AutoID];
        // 布局模型存在
        if (selectedDeviceDetailLayout) {
            [self changeFollowViewImageWithStatus:DeviceViewImageStatusForHighlight inArray:@[selectedDeviceDetailLayout]];
        } else { // 选中的为公共设备
            NSIndexPath *cellIndexPath = nil;
            if (self.selectedOtherViewType == OtherViewTypeCommonDevice) {
                cellIndexPath  = [NSIndexPath indexPathForRow:[kCommonDevices indexOfObject:_selectedDevice] inSection:0];
            } else {
                cellIndexPath = [NSIndexPath indexPathForRow:[kMusicFile indexOfObject:_selectedDevice] inSection:0];
            }
            
            [self setCellHighlightWithCollectionView:self.commonDeviceCollectionView indexPath:cellIndexPath];
        }
        
        
        [self showDeviceInfoByIsBatch:NO];
        
    }
}
/*
- (void)setSelectedDeviceType:(NSString *)selectedDeviceType
{
    if (_selectedDeviceType != selectedDeviceType) {
        if (_selectedDeviceType) {// 原来的取消选中
            [self changeFollowViewImageWithStatus:DeviceViewImageStatusForNormal inArray:[self getAllDetailOfAreaScreenWithDeviceType:_selectedDeviceType]];
        }
        _selectedDeviceType = nil;
        _selectedDeviceType = [selectedDeviceType copy];
        if (!selectedDeviceType) {
            return;
        }
        // 选中类型,则不选中设备
        self.selectedDevice = nil;
        [self showDeviceInfoByIsBatch:YES];
        
        
        [self changeFollowViewImageWithStatus:DeviceViewImageStatusForHighlight inArray:[self getAllDetailOfAreaScreenWithDeviceType:_selectedDeviceType]];
    }
}*/

#pragma mark 修改视角模式
- (void)setCurrentViewpointType:(NSString *)currentViewpointType
{
    self.lastViewpointType = _currentViewpointType;
    NSInteger index = [self.viewpointTypeArray indexOfObject:currentViewpointType];
    // 视角5个按钮的选中
    for (UIView *view in self.viewpointButtonsView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.tag == index) {
                ((UIButton *)view).selected = YES;
            } else {
                ((UIButton *)view).selected = NO;
            }
        }
    }
    
    if (_currentViewpointType != currentViewpointType) {
        _currentViewpointType = nil;
        _currentViewpointType = currentViewpointType;
        
    }
    [self setCurrentMode:ActualModeTypeNormal];
}

#pragma mark - 显示更改布局的view
- (void)showViewsForChangeLayout:(BOOL)isShow
{
    self.saveButton.hidden = !isShow;
    self.cancelButton.hidden = !isShow;
    self.trashImageView.hidden = !isShow;
}

#pragma mark 修改模式后,根据模式更新界面
- (void)setCurrentMode:(ActualModeType)currentMode
{
    _currentMode = currentMode;
    // 默认隐藏
    self.showQuickChooseButton.hidden = YES;
    [self showViewsForChangeLayout:NO];
    self.screenConfigShadeView.hidden = YES;
//    // 操作界面默认隐藏
//    if (self.operatioinView.hidden == NO) {
//        [self.operatioinView addTransitionWithType:kRightViewTransitionType subType:kCATransitionFromLeft duration:0.25 key:@"transition"];
        self.operatioinView.hidden = YES;
//    }
    // 默认图片不可点击()
    self.actualImageViewTapGR.enabled = NO;
    // 视角切换默认隐藏
    self.viewpointButtonsView.hidden = YES;
    self.deviceInfoBackgroundView.hidden = YES;
    
    if (_currentMode == ActualModeTypeNormal) {
        
        if (kActualImage(self.currentViewpointType)) {
            self.actualImageView.image = kActualImage(self.currentViewpointType);
        } else {
            self.actualImageView.image = [UIImage imageNamed:@"placeholderImage"];
        }
       
        // 移除原先所有设备
        for (UIView *view in self.contentView.subviews) {
            if ([view isKindOfClass:[WFFFollowHandsView class]]) {
                [view removeFromSuperview];
            }
        }
            /*
             1.删除本地存储的布局配置中,多余的ID(后台删除了某ID)
             2.将可用的布局取出来,布局到界面上
             3.将未布局的设备存入devicesArray [为nil时,说明所有设备都已经布局了]
             */
    
        [self checkDevices];
        
        // 场景配置的遮罩层
        [self showShadeView:NO];
        self.actualImageView.alpha = 1;
        self.showQuickChooseButton.hidden = NO;
        // 操作界面显示(视角切换/更改布局/更改底图)
        self.operatioinView.hidden = NO;
        
        // 显示视角切换(3秒消失)
        [self startTimerForAutoHideViewpointButtonsView];
        [self setDeviceViewGREnable:YES withType:@"move"];
        [self setDeviceViewGREnable:NO withType:@"longPress"];
        [self setDeviceViewGREnable:YES withType:@"click"];
        self.actualImageViewTapGR.enabled = YES;
    } else if (_currentMode == ActualModeTypeConfig) {
        if ([self.devicesArray count] == 0) {
            [WFFProgressHud showErrorStatus:@"没有可添加设备!"];
            self.currentMode = ActualModeTypeNormal;
            return;
        }
        
        [self showShadeView:YES];
        
        self.actualImageView.alpha = 1;
        
        [self.deviceCollectionView reloadData];
        
    } else if(_currentMode == ActualModeChangeScreen){
        // 显示按钮
        [self showViewsForChangeLayout:YES];

        [self showShadeView:NO];
        self.actualImageView.alpha = 0.5;
        [self setDeviceViewGREnable:YES withType:@"move"];
        [self setDeviceViewGREnable:NO withType:@"click"];
        [self setDeviceViewGREnable:NO withType:@"longPress"];
    } else {// 操作状态
        [self showShadeView:NO];
        self.actualImageView.alpha = 1;
        self.operatioinView.hidden = NO;
        [self setDeviceViewGREnable:NO withType:@"move"];
        [self setDeviceViewGREnable:NO withType:@"longPress"];
        [self setDeviceViewGREnable:NO withType:@"click"];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - UIImagePickerController
- (void)showImagePickerControllerWithTitle:(NSString *)title cancleHandle:(void (^)())cancleHandle
{
    self.imagePickerController = [[UIImagePickerController alloc]init];
    
    _imagePickerController.delegate = self;
    
    // 判断支持来源类型(拍照,照片库,相册)
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL isPhotoLibrarySupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL isSavedPhotosAlbumSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    if (isCameraSupport) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ((AppDelegate *)[UIApplication sharedApplication].delegate).isMaskAllForInterfaceOrientations = YES;

            //指定使用照相机模式,可以指定使用相册／照片库
            weakSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            /// 相机相关 [sourceType不设置为Camera.下面属性无法设置]
            //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
            weakSelf.imagePickerController.showsCameraControls  = YES;
            //设置当拍照完或在相册选完照片后，是否跳到编辑模式进行图片剪裁。只有当showsCameraControls属性为true时才有效果
            weakSelf.imagePickerController.allowsEditing = YES;
            // 支持的摄像头类型(前置 后置)
            BOOL isRearSupport = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
            if (isRearSupport) {
                //设置使用后置摄像头，可以使用前置摄像头
                weakSelf.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            } else {
                weakSelf.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            //设置闪光灯模式 自动
            weakSelf.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            //设置相机支持的类型，拍照和录像
            weakSelf.imagePickerController.mediaTypes = @[@"public.image"];// public.movie(录像)
            
            [weakSelf presentViewController:weakSelf.imagePickerController animated:YES completion:nil];
        }]];
    }
    
    if (isPhotoLibrarySupport) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从照片库选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ((AppDelegate *)[UIApplication sharedApplication].delegate).isMaskAllForInterfaceOrientations = YES;
            //指定使用照相机模式,可以指定使用相册／照片库
            weakSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakSelf presentViewController:weakSelf.imagePickerController animated:YES completion:nil];
        }]];
    }
    
    if (isSavedPhotosAlbumSupport) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ((AppDelegate *)[UIApplication sharedApplication].delegate).isMaskAllForInterfaceOrientations = YES;

            //指定使用照相机模式,可以指定使用相册／照片库
            weakSelf.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [weakSelf presentViewController:weakSelf.imagePickerController animated:YES completion:nil];
        }]];
    }
    // 取消
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).isMaskAllForInterfaceOrientations = NO;

        if (cancleHandle) {
            cancleHandle();
        }
    }]];
    
    if (!(isCameraSupport || isPhotoLibrarySupport || isSavedPhotosAlbumSupport)) { // 三种都不支持
        alertController.title = @"无法找到可用图片源,请检查设备后重试";
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    ((AppDelegate *)[UIApplication sharedApplication].delegate).isMaskAllForInterfaceOrientations = NO;

    UIImage *image = info[UIImagePickerControllerEditedImage] ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
    kSetActualImage(self.currentViewpointType, image);
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.currentMode = ActualModeTypeNormal;
//    self.actualImageView.image = [Common shareCommon].actualImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    ((AppDelegate *)[UIApplication sharedApplication].delegate).isMaskAllForInterfaceOrientations = NO;

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 控件点击事件
- (IBAction)saveButtonAction:(UIButton *)sender {
    // 保存场景(为默认场景)
    [self saveDeviceLayout];
    
    // setter,normal自动将场景配置应用到界面
    self.currentMode = ActualModeTypeNormal;
}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    self.currentMode = ActualModeTypeNormal;
}

- (IBAction)cancelButtonActionForAddScreen:(UIButton *)sender {
    self.currentMode = ActualModeTypeNormal;
}

- (IBAction)putInOrderButtonAction:(UIButton *)sender {
    [self layoutInOrder];
}

- (void)showProcess
{
    if (!_processView) {
        self.processView = [[ProcessView alloc] init];
        _processView.translatesAutoresizingMaskIntoConstraints = NO;
        [_processBackgroundView addSubview:_processView];
        _processView.doSomethingBlock = ^(NSString *selectedProcessID, BOOL isStart) {
                [[SocketManager shareSocketManager] doByProcessWithProcessID:selectedProcessID isStart:isStart resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
                    if (isSuccess) {
                        kLog(@"流程处理成功");
                    } else {
                        kLog(@"流程处理失败");
                    }
                }];
            };
        // 设置约束
        [_processView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_processView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_processView autoSetDimension:ALDimensionWidth toSize:630];
        [_processView autoSetDimension:ALDimensionHeight toSize:420];
    }
    
    _processView.processArray = kProcessByCurrentArea;
}

- (IBAction)showProcessViewButtonAction:(UIButton *)sender {
    [self updateViewHideOrShowByType:TopViewTypeForProcessView];
    [self showProcess];
    if (!kProcessByCurrentArea) {
        __weak typeof(self) weakSelf = self;
        [[Common shareCommon] loadProcessDataListWithCompletionHandle:^(BOOL isSuccess, NSString *errorDescription) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    weakSelf.processView.processArray = kProcessByCurrentArea;
                } else {
                    weakSelf.processView.errorDescription = errorDescription;
                }
             });
        }];
    }
    
}

- (IBAction)okButtonActionForAddScreen:(UIButton *)sender {
    // 保存场景(为默认场景)
    [self saveDeviceLayout];
    // setter,normal自动将场景配置应用到界面
    self.currentMode = ActualModeTypeNormal;
        
}

#pragma mark - 3秒后自动隐藏 视角切换按钮组(点击按钮租中的任何一个,会刷新时间)
- (void)startTimerForAutoHideViewpointButtonsView
{
    // 如果原先已经隐藏,则显示
    if (self.viewpointButtonsView.hidden) {
        self.viewpointButtonsView.hidden = NO;
    }
    
    // 静态变量计时
    static CGFloat secondsToHiddenViewpointButtonView = 0.0f;
    // 已经为0,说明计时已经停止,则重新计时
    if (secondsToHiddenViewpointButtonView == 0.0f) {
        secondsToHiddenViewpointButtonView = 2.0f;
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.5f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(timer, ^{
            if (secondsToHiddenViewpointButtonView > 0.0f){
                secondsToHiddenViewpointButtonView -= 0.5f;
            } else { // == 0 -- 计时结束,停止计时,更改状态
                dispatch_source_cancel(timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    secondsToHiddenViewpointButtonView = 0.0f;
                    weakSelf.viewpointButtonsView.hidden = YES;
                });
            }
        });
        // 开启定时
        dispatch_resume(timer);
    } else { // > 0  -- 已经显示,刷新计时时间
        secondsToHiddenViewpointButtonView = 2.0f;
    }
}

- (IBAction)addDeviceButtonAction:(UIButton *)sender {
    self.currentMode = ActualModeTypeConfig;
}

- (IBAction)changeActualImageButtonAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [self showImagePickerControllerWithTitle:@"更改实景图" cancleHandle:^{
        weakSelf.currentMode = ActualModeTypeNormal;
    }];
}

- (IBAction)changeCurrenScreenButtonAction:(UIButton *)sender {
    self.currentMode = ActualModeChangeScreen;
}

- (IBAction)viewpointButtonAction:(UIButton *)sender {
    if (self.currentViewpointType != self.viewpointTypeArray[sender.tag]) {
        self.currentViewpointType = self.viewpointTypeArray[sender.tag];
    }
    // 开启自动隐藏视角切换的定时器
    [self startTimerForAutoHideViewpointButtonsView];
}

- (IBAction)showQuickChooseButtonAction:(UIButton *)sender {
    // 操作界面隐藏(视角切换/更改布局/更改底图)
    [self updateViewHideOrShowByType:TopViewTypeForCommonDeviceView];
    
    if ([kCommonDevices count] > 0) { // 根据数据有无,隐藏或显示collectionView
        [self.commonDeviceBackgroundView viewWithTag:777].hidden = YES;
    } else {
        [self.commonDeviceBackgroundView viewWithTag:777].hidden = NO;
    }
}

- (BOOL)checkPermissionsByDevice:(DeviceForUser *)device
{
    // 假设没有批量操作
    if (kCurrentUser.level < device.needLevel) {
        [WFFProgressHud showErrorStatus:@"对不起,您没有权限操控该设备!"];
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)processBackgroundViewTapGRAction:(UITapGestureRecognizer *)sender {
    [self updateViewHideOrShowByType:TopViewTypeNone];
}
- (IBAction)otherViewButtonAction:(UIButton *)sender {
    if (self.selectedOtherViewType != (OtherViewType)sender.tag) {
        self.selectedOtherViewType = (OtherViewType)sender.tag;
        
        [self.commonDeviceCollectionView reloadData];
    }
}
@end
