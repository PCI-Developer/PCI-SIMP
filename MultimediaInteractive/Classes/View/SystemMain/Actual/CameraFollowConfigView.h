//
//  CameraFollowConfigView.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/24.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "DeviceInfoBaseView.h"

#define kHintForCameraFollow @"选择跟随的摄像头"

@interface CameraFollowConfigView : UIView

// 点击应用回调
@property (nonatomic, copy) void (^applyButtonClickedBlock)(DeviceForUser *selectedCamera);

// 摄像头设备的数组
@property (nonatomic, strong) NSArray *cameraArray;

@property (nonatomic, copy) NSString *selectedUEQP_ID;


@end
