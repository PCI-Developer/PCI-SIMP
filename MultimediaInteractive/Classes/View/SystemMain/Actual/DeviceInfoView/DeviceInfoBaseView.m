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

- (void)sliderLeaveFocus:(NSNotification *)sender {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderLeaveFocus:) name:kSliderLeaveFocusNotification object:nil];
    
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

- (IBAction)orientationButtonTouchDown:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(deviceInfoView:orientationButtonTouchDown:)]) {
        [self.delegate deviceInfoView:self orientationButtonTouchDown:sender];
    }
}

- (IBAction)fsdf:(id)sender {
    NSLog(@"fdsf");
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

#pragma mark - 更新SliderValue的提示文字
- (IBAction)sliderValueChanged:(WFFCircularSlider *)sender
{
    UILabel *label = (UILabel *)[[UIApplication sharedApplication].keyWindow viewWithTag:kTagForLabelOfVolumeSlider];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = kTagForLabelOfVolumeSlider;
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor lightGrayColor];
        label.shadowOffset = CGSizeMake(1, 1);
        label.textAlignment = NSTextAlignmentCenter;
        //        label.backgroundColor = [UIColor cyanColor];
        [[UIApplication sharedApplication].keyWindow addSubview:label];
    }
    label.hidden = NO;
    label.alpha = 1;
    label.text = [NSString stringWithFormat:@"%.0f", sender.value * 100];
    CGRect sliderThumbRect = [sender convertRect:sender.bounds toView:[UIApplication sharedApplication].keyWindow];
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
    UILabel *label = (UILabel *)[[UIApplication sharedApplication].keyWindow viewWithTag:kTagForLabelOfVolumeSlider];
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        label.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // 隐藏sliderValueLabel
        label.hidden = YES;
    }];
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
@end
