//
//  DeviceInfoView.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/23.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFFCircularSlider.h"
#import "WFFDropdownList.h"
@class DeviceInfoBaseView;
@protocol DeviceInfoBaseViewDelegate <NSObject>

@optional
- (void)deviceInfoViewOpenButtonClicked:(DeviceInfoBaseView *)deviceInfoView;
- (void)deviceInfoViewCloseButtonClicked:(DeviceInfoBaseView *)deviceInfoView;
- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView orientationButtonTouchDown:(UIButton *)button;
- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView orientationButtonTouchUp:(UIButton *)button;
- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView channelIndexChanged:(NSInteger)channelIndex;
- (void)deviceInfoViewSliderLeaveFoucsWithValue:(CGFloat)value;
- (void)deviceInfoViewVolumeAddButtonClicked;
- (void)deviceInfoViewVolumeMinusButtonClicked;
- (void)deviceInfoView:(DeviceInfoBaseView *)deviceInfoView cameraFollowButtonClicked:(UIButton *)button;
- (void)deviceInfoViewCheckBoxClicked:(DeviceInfoBaseView *)deviceInfoView;
@end


@interface DeviceInfoBaseView : UIView

@property (nonatomic, assign) BOOL isBatch;

@property (nonatomic, strong) DeviceForUser *device;

@property (nonatomic, assign) id <DeviceInfoBaseViewDelegate> delegate;

@property (nonatomic, copy) NSString *nibName;

// 摄像头时, checkBox的勾选状态
@property (nonatomic, assign) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;

@property (nonatomic, weak) IBOutlet UIImageView *deviceInfoImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceInfoNameLabel;
@property (weak, nonatomic) IBOutlet WFFDropdownList *channelDropdown;
@property (nonatomic, strong) NSArray *channelArray;
@property (nonatomic, assign) NSInteger selectedChannel;

@property (weak, nonatomic) IBOutlet WFFCircularSlider *volumeSlider;

@property (nonatomic, weak) IBOutlet UIButton *deviceInfoOpenButton;
@property (nonatomic, weak) IBOutlet UIButton *deviceInfoCloseButton;
@property (nonatomic, weak) IBOutlet UIView *orientationView;
@property (weak, nonatomic) IBOutlet UIButton *cameraFollowConfigButton;

- (IBAction)sliderValueChanged:(WFFCircularSlider *)sender;

- (instancetype)initWithNibName:(NSString *)nibName;

- (IBAction)openButtonClicked:(UIButton *)sender;

- (IBAction)closeButtonClicked:(UIButton *)sender;

- (IBAction)orientationButtonTouchDown:(UIButton *)sender;

- (IBAction)orientationButtonTouchUp:(UIButton *)sender;


- (IBAction)cameraFollowConfigButtonClicked:(UIButton *)sender;

- (IBAction)checkBoxClicked:(UITapGestureRecognizer *)sender;

@end

