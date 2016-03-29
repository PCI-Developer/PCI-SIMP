//
//  CameraFollowConfigView.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/24.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "CameraFollowConfigView.h"
#import "WFFDropdownList.h"
@interface CameraFollowConfigView ()<WFFDropdownListDelegate>

@property (weak, nonatomic) IBOutlet WFFDropdownList *cameraDropdownList;

@property (nonatomic, strong) NSMutableArray *titleArray;

- (IBAction)applyButtonClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *orientationView;

@property (nonatomic, strong) DeviceForUser *selectedCamera;

@end

@implementation CameraFollowConfigView

static BOOL isDeviceInfoOrientationButtonTouchDown = NO;

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.cameraDropdownList.textColor = [UIColor whiteColor];
    self.cameraDropdownList.font = [UIFont systemFontOfSize:20];
}


- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow == [UIApplication sharedApplication].keyWindow) {
        self.cameraDropdownList.textColor = [UIColor whiteColor];
        self.cameraDropdownList.tableTextColor = [UIColor whiteColor];
        self.cameraDropdownList.listCellBackgroundImage = [UIImage imageNamed:@"dropdownListCellBg.png"];
        self.cameraDropdownList.listCellBackgroundImageSelected = [UIImage imageNamed:@"dropdownListCellBgSelected.png"];
        self.cameraDropdownList.maxCountForShow = 3;
        self.cameraDropdownList.rightImage = [UIImage imageNamed:@"dropdownListRightImage1.png"];
        self.cameraDropdownList.rightImageSelected = [UIImage imageNamed:@"dropdownListRightImageSelected1.png"];
        self.cameraDropdownList.backgroundImage = [UIImage imageNamed:@"dropdownListBackground.png"];
    }
}

- (IBAction)orientationTouchDown:(UIButton *)sender {
    if (!self.selectedUEQP_ID) {
        return;
    }
    if (kCurrentUser.level < self.selectedCamera.needLevel) {
        [WFFProgressHud showErrorStatus:@"对不起,您没有权限操控该设备!"];
        return;
    }
    isDeviceInfoOrientationButtonTouchDown = YES;
    kDeviceStartPTZ(self.selectedCamera, sender.tag, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
        if (isSuccess) {
            kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 开始调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
        } else {
            //            [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
        }
    });
}
- (IBAction)orientationTouchUp:(UIButton *)sender {
    if (!self.selectedUEQP_ID) {
        return;
    }
    if (!isDeviceInfoOrientationButtonTouchDown) { // 按下去没权限
        return;
    }
    isDeviceInfoOrientationButtonTouchDown = NO;
    kDeviceStopPTZ(self.selectedCamera, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
        if (isSuccess) {
            
            kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 停止调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
        } else {
            //            [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
        }
    });
}



- (IBAction)applyButtonClicked:(UIButton *)sender {
    NSInteger selectedIndex = self.cameraDropdownList.selectedIndex;
    DeviceForUser *selectedCamera = nil;
    if (selectedIndex > 0) {
        selectedCamera = self.cameraArray[selectedIndex - 1];
    }
    if (self.applyButtonClickedBlock) {
        self.applyButtonClickedBlock(selectedCamera);
    }
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setHidden:hidden animated:animated];
    if (!_cameraDropdownList.delegate) {
        _cameraDropdownList.delegate = self;
    }
}

- (NSMutableArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

- (void)setCameraArray:(NSArray *)cameraArray
{
    [self.titleArray removeAllObjects];
    [self.titleArray addObject:kHintForCameraFollow];
    if (_cameraArray != cameraArray) {
        _cameraArray = nil;
        _cameraArray = cameraArray;
        for (DeviceForUser *device in cameraArray) {
            [self.titleArray addObject:device.UEQP_Name];
        }
    }
    self.cameraDropdownList.dataArray = self.titleArray;
}

- (void)setSelectedUEQP_ID:(NSString *)selectedUEQP_ID
{
    NSInteger selectedIndex = 0;
    if (_selectedUEQP_ID != selectedUEQP_ID) {
        _selectedUEQP_ID = nil;
        _selectedUEQP_ID = [selectedUEQP_ID copy];
        self.selectedCamera = [[Common shareCommon] getDeviceWithUEQP_ID:_selectedUEQP_ID];
        
    }
    for (DeviceForUser *device in _cameraArray) {
        if ([device.UEQP_ID isEqualToString:selectedUEQP_ID]) {
            selectedIndex++;
            break;
        }
    }
    self.cameraDropdownList.selectedIndex = selectedIndex;
    if (selectedIndex != 0) {
        self.orientationView.userInteractionEnabled = YES;
    } else {
        self.orientationView.userInteractionEnabled = NO;
    }
}

- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex
{
    
    DeviceForUser *result = nil;
    if (selectedIndex != 0) {
        result = self.cameraArray[selectedIndex - 1];
        self.selectedUEQP_ID = result.UEQP_ID;
    } else {
        self.selectedUEQP_ID = nil;
    }
}

@end
