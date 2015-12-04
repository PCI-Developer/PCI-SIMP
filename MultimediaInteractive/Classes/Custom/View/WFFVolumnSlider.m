//
//  VolumnSlider.m
//  slideViewTest
//
//  Created by 吴非凡 on 15/10/19.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "WFFVolumnSlider.h"

#define kSideImageWidth 20

#define kSideImageHeight 20

#define kSideMargin 15

#define kTrackHeight 5

#define kThumbWidth 30

#define kThumbHeight 30

@implementation WFFVolumeSlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    if (!_trackHeight) {
        return [super trackRectForBounds:bounds];
    }
    return CGRectMake(0, (bounds.size.height - _trackHeight) / 2, bounds.size.width, _trackHeight);
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectMake(- kSideMargin - kSideImageWidth, (bounds.size.height - kSideImageHeight) / 2, kSideImageWidth, kSideImageHeight);
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width + kSideMargin, (bounds.size.height - kSideImageHeight) / 2, kSideImageWidth, kSideImageHeight);
}


- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGFloat centerX = value / 1.0f * rect.size.width;
    return CGRectMake(centerX - kThumbWidth / 2, (bounds.size.height - kThumbHeight) / 2, kThumbWidth, kThumbHeight);
}

- (void)setTrackHeight:(CGFloat)trackHeight
{
    if (_trackHeight != trackHeight) {
        _trackHeight = trackHeight;
    }
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    [self setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage
{
    if (_minimumTrackImage != minimumTrackImage) {
        _minimumTrackImage = nil;
        _minimumTrackImage = minimumTrackImage;
        if (_minimumTrackImage) {
            self.minimumTrackTintColor = [UIColor colorWithPatternImage:_minimumTrackImage];
        } else {
            self.minimumTrackTintColor = [UIColor blackColor];
        }
    }
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage
{
    if (_maximumTrackImage != maximumTrackImage) {
        _maximumTrackImage = nil;
        _maximumTrackImage = maximumTrackImage;
        if (_maximumTrackImage) {
            self.maximumTrackTintColor = [UIColor colorWithPatternImage:_maximumTrackImage];
        } else {
            self.maximumTrackTintColor = [UIColor blackColor];
        }
    }
}
@end
