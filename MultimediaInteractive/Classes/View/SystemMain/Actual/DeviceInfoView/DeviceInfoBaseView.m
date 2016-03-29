//
//  DeviceInfoView.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/23.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "DeviceInfoBaseView.h"

@interface DeviceInfoBaseView () <WFFDropdownListDelegate>



@end

@implementation DeviceInfoBaseView


- (void)awakeFromNib
{
    
    if (_volumeSlider) {
        _volumeSlider.backgroundImage = [UIImage imageNamed:@"volBg"];
        _volumeSlider.tintImage = [UIImage imageNamed:@"volTint"];
        _volumeSlider.thumbImage = [UIImage imageNamed:@"volThumb"];
    }
    _channelDropdown.delegate = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)volumeSliderLeaveFocus:(NSNotification *)sender {
    WFFCircularSlider *slider = (WFFCircularSlider *)sender.object;
    if ([self.delegate respondsToSelector:@selector(deviceInfoViewVolumeSliderLeaveFoucsWithValue:)]) {
        [self.delegate deviceInfoViewVolumeSliderLeaveFoucsWithValue:slider.value];
    }
}

- (instancetype)initWithNibName:(NSString *)nibName
{
    self = [[UINib nibWithNibName:nibName bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
    if (self != nil) {
        _isBatch = NO;
        _nibName = [nibName copy];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeSliderLeaveFocus:) name:kSliderLeaveFocusNotification object:nil];
    
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (IBAction)openButtonClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(deviceInfoViewOpenButtonClicked:)]) {
        [self.delegate deviceInfoViewOpenButtonClicked:self];
    }
}

- (IBAction)closeButtonClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(deviceInfoViewCloseButtonClicked:)]) {
        [self.delegate deviceInfoViewCloseButtonClicked:self];
    }
}

- (IBAction)controlMusicFileButtonClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(deviceInfoView:controlMusicFileButtonClicked:)]) {
        [self.delegate deviceInfoView:self controlMusicFileButtonClicked:sender];
    }
}

- (IBAction)orientationButtonTouchDown:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(deviceInfoView:orientationButtonTouchDown:)]) {
        [self.delegate deviceInfoView:self orientationButtonTouchDown:sender];
    }
}


- (IBAction)orientationButtonTouchUp:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(deviceInfoView:orientationButtonTouchUp:)]) {
        [self.delegate deviceInfoView:self orientationButtonTouchUp:sender];
    }
}


- (IBAction)cameraFollowConfigButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(deviceInfoView:cameraFollowButtonClicked:)]) {
        [self.delegate deviceInfoView:self cameraFollowButtonClicked:sender];
    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    if (_isSelected != isSelected) {
        _isSelected = isSelected;
        self.checkBoxImageView.highlighted = isSelected;
    }
}

- (IBAction)checkBoxClicked:(UITapGestureRecognizer *)sender {
    self.isSelected = !_isSelected;
    if ([self.delegate respondsToSelector:@selector(deviceInfoViewCheckBoxClicked:)]) {
        [self.delegate deviceInfoViewCheckBoxClicked:self];
    }
}

- (IBAction)brightnessSliderLeaveFoucs:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(deviceInfoView:brightnessSliderWithValue:)]) {
        [self.delegate deviceInfoView:self brightnessSliderWithValue:sender.value];
    }
}

#pragma mark - 更新SliderValue的提示文字
- (IBAction)sliderValueChanged:(id)sender
{
    UILabel *label = (UILabel *)[self viewWithTag:kTagForLabelOfVolumeSlider];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = kTagForLabelOfVolumeSlider;
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor lightGrayColor];
        label.shadowOffset = CGSizeMake(1, 1);
        label.textAlignment = NSTextAlignmentCenter;
        //        label.backgroundColor = [UIColor cyanColor];
        [self addSubview:label];
    }
    
    [self bringSubviewToFront:label];
    
    label.hidden = NO;
    label.alpha = 1;
    
    CGFloat value = [sender isKindOfClass:[WFFCircularSlider class]] ? ((WFFCircularSlider *)sender).value : ((UISlider *)sender).value;
    
    label.text = [NSString stringWithFormat:@"%.0f", value * 100];
    CGRect sliderThumbRect = [sender convertRect:((UIControl *)sender).bounds toView:self];
    label.frame = CGRectMake(CGRectGetMidX(sliderThumbRect) - 40 / 2, CGRectGetMinY(sliderThumbRect) - 30, 40, 30);
    
    static NSTimer *timer;
    // 创建定时器,1秒后隐藏音量大小文本
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(dismissVolumeSliderValueLabel:)
                                           userInfo:nil repeats:NO];
}

- (void)dismissVolumeSliderValueLabel:(NSTimer *)sender
{
    
    UILabel *label = (UILabel *)[self viewWithTag:kTagForLabelOfVolumeSlider];
    if (label.hidden) {
        return;
    }
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        label.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // 隐藏sliderValueLabel
        label.hidden = YES;
    }];
}

- (void)hiddenLabelForSlider
{
    UILabel *label = (UILabel *)[self viewWithTag:kTagForLabelOfVolumeSlider];

    if (label.hidden) {
        return;
    }
    label.hidden = YES;
}

- (void)setIsBatch:(BOOL)isBatch
{
    _isBatch = isBatch;
    [self.cameraFollowConfigButton setEnabled:!isBatch];
    [self setOrientationViewEnabled:!isBatch];
}

- (void)setOrientationViewEnabled:(BOOL)enabled
{
    for (UIView *view in self.orientationView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [((UIButton *)view) setEnabled:enabled];
        }
    }
}

- (void)setChannelArray:(NSArray *)channelArray
{
    if (_channelArray != channelArray) {
        _channelArray = nil;
        _channelArray = channelArray;
        _channelDropdown.dataArray = channelArray;
        _channelDropdown.selectedIndex = 0;
    }
}

- (void)setSelectedChannel:(NSInteger)selectedChannel
{
    if (_selectedChannel != selectedChannel) {
        _selectedChannel = selectedChannel;
        _channelDropdown.selectedIndex = 0;
    }
}

- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex
{
    _selectedChannel = selectedIndex;
    if ([_delegate respondsToSelector:@selector(deviceInfoView:channelIndexChanged:)]) {
        [_delegate deviceInfoView:self channelIndexChanged:selectedIndex];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow == [UIApplication sharedApplication].keyWindow) {
        if (!self.channelDropdown) {
            return;
        }
        self.channelDropdown.textColor = [UIColor whiteColor];
        self.channelDropdown.tableTextColor = [UIColor whiteColor];
        self.channelDropdown.listCellBackgroundImage = [UIImage imageNamed:@"dropdownListCellBg.png"];
        self.channelDropdown.listCellBackgroundImageSelected = [UIImage imageNamed:@"dropdownListCellBgSelected.png"];
        self.channelDropdown.maxCountForShow = 3;
        self.channelDropdown.rightImage = [UIImage imageNamed:@"dropdownListRightImage1.png"];
        self.channelDropdown.rightImageSelected = [UIImage imageNamed:@"dropdownListRightImageSelected1.png"];
        self.channelDropdown.backgroundImage = [UIImage imageNamed:@"dropdownListBackground.png"];
    }
}
@end
