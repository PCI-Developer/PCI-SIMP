//
//  WFFCheckBox.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/12/8.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "WFFCheckBox.h"

@interface WFFCheckBox ()

@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIImageView *tintImageView;
@end

@implementation WFFCheckBox


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setUp];
}

/**
 *  初始化
 */
- (void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGRAction:)]];
}

- (void)tapGRAction:(UITapGestureRecognizer *)sender
{
    self.selected = !self.selected;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

/**
 *  横竖屏
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateUI];
    
    [self updateStatus];
}

#pragma mark - lazy loading
- (UIImageView *)leftImageView
{
    if (!_leftImageView) {
        self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
        [self addSubview:_leftImageView];
    }
    return _leftImageView;
}

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    return _backgroundImageView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.height, 0, self.bounds.size.width - self.bounds.size.height, self.bounds.size.height)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        [self insertSubview:_textLabel aboveSubview:self.backgroundImageView];
    }
    return _textLabel;
}

- (UIImageView *)tintImageView
{
    if (!_tintImageView) {
        self.tintImageView = [[UIImageView alloc] initWithFrame:self.textLabel.frame];
        [self insertSubview:_tintImageView aboveSubview:self.textLabel];
    }
    return _tintImageView;
}

#pragma mark - setter
- (void)setLeftImage:(UIImage *)leftImage
{
    if (_leftImage != leftImage) {
        _leftImage = nil;
        _leftImage = leftImage;
        self.leftImageView.image = leftImage;
    }
}

- (void)setLeftImageSelected:(UIImage *)leftImageSelected
{
    if (_leftImageSelected != leftImageSelected) {
        _leftImageSelected = nil;
        _leftImageSelected = leftImageSelected;
        self.leftImageView.highlightedImage = leftImageSelected;
    }
}

- (void)setTintImage:(UIImage *)tintImage
{
    if (_tintImage != tintImage) {
        _tintImage = nil;
        _tintImage = tintImage;
        self.tintImageView.image = _tintImage;
        if (!_tintImage && !_tintImageSelected && _tintImageView) {
            [_tintImageView removeFromSuperview];
            _tintImageView = nil;
        }
    }
}

- (void)setTintImageSelected:(UIImage *)tintImageSelected
{
    if (_tintImageSelected != tintImageSelected) {
        _tintImageSelected = nil;
        _tintImageSelected = tintImageSelected;
        self.tintImageView.highlightedImage = _tintImageSelected;
        if (!_tintImageSelected && !_tintImage && _tintImageView) {
            [_tintImageView removeFromSuperview];
            _tintImageView = nil;
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (_backgroundImage != backgroundImage) {
        _backgroundImage = nil;
        _backgroundImage = backgroundImage;
        self.backgroundImageView.image = backgroundImage;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateStatus];
}

/**
 *  根据selected的值更新文字和图片的显示
 */
- (void)updateStatus
{
    
    [self.leftImageView setHighlighted:self.selected];
    
    if (self.selected) {
        if (_textSelected) {
            self.textLabel.text = _textSelected;
        } else {
            self.textLabel.text = _text;
        }
    } else {
        if (_text) {
            self.textLabel.text = _text;
        }
    }
    
    if (_tintImage || _tintImageSelected) {
        [self.tintImageView setHighlighted:self.selected];
    }
}

/**
 *  更新控件的frame
 */
- (void)updateUI
{
    self.leftImageView.frame = CGRectMake(self.leftEdgeInsets.left, self.leftEdgeInsets.top, self.bounds.size.height - self.leftEdgeInsets.top - self.leftEdgeInsets.bottom, self.bounds.size.height - self.leftEdgeInsets.top - self.leftEdgeInsets.bottom);
    
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(_leftImageView.frame) + _tintEdgeInsets.left, _tintEdgeInsets.top, self.bounds.size.width - CGRectGetMaxX(_leftImageView.frame) - _tintEdgeInsets.left - _tintEdgeInsets.right, self.bounds.size.height - _tintEdgeInsets.top - _tintEdgeInsets.bottom);
    
    self.tintImageView.frame = self.textLabel.frame;
}

@end
