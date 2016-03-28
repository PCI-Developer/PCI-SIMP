//
//  WFFDropdownList.m
//  Custom
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//


#define kImageIconSize 32
#define kImageIconMargin 10
#import "WFFDropdownList.h"
@interface WFFDropdownList () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _lineHeight;
    CGFloat _lineWidth;
    CGRect _rectOnKeyWindow;
}



@property (nonatomic, assign) BOOL isOpen;// 是否打开下拉列表

@property (nonatomic, strong) UITableView *dropdownTalbeView;

@property (nonatomic, strong) UILabel *currentLabel;

@property (nonatomic, assign) NSInteger countOfLinesForShow;

@property (nonatomic, strong) UIView *shadeView;

@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *listBackgroundImageView;

@end

@implementation WFFDropdownList

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array
{
    if (self = [super initWithFrame:frame]) {
        
        self.dataArray = array;
        
        [self setUp];
        
        self.isOpen = NO;
        
    }
    return self;
}

- (void)awakeFromNib
{
    
    
    [self setUp];
    
    self.isOpen = NO;
    
}
#pragma mark - 私有方法
- (void)setUp
{
    if (_listCellHeight) {
        
        _lineHeight = _listCellHeight;
    } else {
        
        _lineHeight = self.frame.size.height;
    }
    _lineWidth = self.frame.size.width;
    
    
    self.listOrientation = ListOrientationDown;
    
    self.maxCountForShow = 5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(currentLabelTapGRAction:)]];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    if (_textColor) {
        label.textColor = _textColor;
    } else {
        label.textColor = [UIColor blackColor];
    }
    if (_font) {
        label.font = _font;
    } else {
        label.font = [UIFont systemFontOfSize:20];
    }
    self.currentLabel = label;
    [self addSubview:_currentLabel];
    
    
    UIView *shadeView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    shadeView.backgroundColor = [UIColor clearColor];
    [shadeView addGestureRecognizer:({
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewTapGRAction:)];
        tapGR.delegate = self;
        tapGR;
    })];
    [[UIApplication sharedApplication].keyWindow addSubview:shadeView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _lineWidth, _lineHeight * _countOfLinesForShow)];
    tableView.bounces = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.layer.borderWidth = 1;
    self.dropdownTalbeView = tableView;
    
    [shadeView addSubview:_dropdownTalbeView];
    
    
    self.shadeView = shadeView;
    
}

- (CGRect)tableViewFrame
{
    CGRect rectOnShadeView = [self convertRect:self.bounds toView:_shadeView];
    if (_listOrientation == ListOrientationDown) {
        return CGRectMake(CGRectGetMinX(rectOnShadeView), CGRectGetMaxY(rectOnShadeView), _lineWidth, _lineHeight * _countOfLinesForShow);
    } else {
        return CGRectMake(CGRectGetMinX(rectOnShadeView), CGRectGetMinY(rectOnShadeView) - _lineHeight * _countOfLinesForShow, _lineWidth, _lineHeight * _countOfLinesForShow);
    }
}

- (void)setDataArray:(NSArray *)dataArray
{
    if (_dataArray != dataArray) {
        _dataArray  = nil;
        _dataArray = dataArray;
        _countOfLinesForShow = [_dataArray count] > _maxCountForShow ? _maxCountForShow : [_dataArray count];
        [_dropdownTalbeView reloadData];
    }
}

- (void)updateUI
{
    
    if (_isOpen) {
        _shadeView.hidden = NO;
        self.dropdownTalbeView.frame = [self tableViewFrame];
        //
        [self.dropdownTalbeView reloadData];
        if (_dataArray) {
            [_dropdownTalbeView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
        
    } else {
        _shadeView.hidden = YES;
    }
}

#pragma mark - setter
- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = nil;
        _textColor = textColor;
        _currentLabel.textColor = textColor;
    }
}

- (void)setFont:(UIFont *)font
{
    if (_font != font) {
        _font = nil;
        _font = font;
        _currentLabel.font = font;
    }
}

- (void)setIsOpen:(BOOL)isOpen
{
    _isOpen = isOpen;
    if (!_isOpen) {
        if (_backgroundImage) {
            _backgroundImageView.image = _backgroundImage;
        } else {
            _backgroundImageView.image = nil;
        }
        if (_rightImage) {
            _rightImageView.image = _rightImage;
        } else {
            _rightImageView.image = nil;
        }
    } else {
        if (_backgroundImageSelected) {
            _backgroundImageView.image = _backgroundImageSelected;
        }
        if (_rightImageSelected) {
            _rightImageView.image = _rightImageSelected;
        }
    }
    [self updateUI];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if ([_dataArray count] > 0) {
        if (_selectedIndex > [_dataArray count] - 1) {
            _selectedIndex = [_dataArray count] - 1;
        }
        _currentLabel.text = _dataArray[_selectedIndex];
    } else {
        _selectedIndex = -1;
    }
}

- (void)setMaxCountForShow:(NSInteger)maxCountForShow
{
    _maxCountForShow = maxCountForShow;
    _countOfLinesForShow = [_dataArray count] > _maxCountForShow ? _maxCountForShow : [_dataArray count];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_listCellHeight) {
        
        _lineHeight = _listCellHeight;
    } else {
        
        _lineHeight = frame.size.height;
    }
    _lineWidth = frame.size.width;
    CGRect rectOnShadeView = [self convertRect:self.bounds toView:_shadeView];
    self.dropdownTalbeView.frame = CGRectMake(CGRectGetMinX(rectOnShadeView), CGRectGetMaxY(rectOnShadeView), _lineWidth, _lineHeight * _countOfLinesForShow);
    self.currentLabel.frame = self.bounds;
}


- (void)updateSubViews
{
    if (_listCellHeight) {
        
        _lineHeight = _listCellHeight;
    } else {
        
        _lineHeight = self.frame.size.height;
    }
    _lineWidth = self.frame.size.width;
    self.dropdownTalbeView.frame = [self tableViewFrame];
    // 刷新重新跑cellFor...  使label居中
    [self.dropdownTalbeView reloadData];
    self.shadeView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    
    
    
    if (_rightImageView) { // 存在
        _currentLabel.frame = (CGRect){0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)};
        _rightImageView.frame = CGRectMake(CGRectGetWidth(self.frame) - kImageIconSize - kImageIconMargin, (CGRectGetHeight(self.frame) - kImageIconSize) / 2, kImageIconSize, kImageIconSize);
    } else {
        _currentLabel.frame = self.bounds;
    }
    
    if (_backgroundImageView) {
        _backgroundImageView.frame = _currentLabel.frame;
    }

    if (_listBackgroundImageView) {
        _listBackgroundImageView.frame = _dropdownTalbeView.frame;
    }
}

#pragma mark - 轻拍手势
#pragma mark Label手势
- (void)currentLabelTapGRAction:(UITapGestureRecognizer *)sender
{
    self.isOpen = !self.isOpen;
}

#pragma mark 遮罩层手势
- (void)shadeViewTapGRAction:(UITapGestureRecognizer *)sender{
    self.isOpen = NO;
}

#pragma mark - 遮罩层手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_dropdownTalbeView.frame, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray ? _dataArray.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] init];
        [cell addSubview:label];
    }
    label.frame = cell.bounds;
    
    if (_tableTextColor) {
        label.textColor = _tableTextColor;
    }
    
    UIImage *backImage = nil;
    if (indexPath.row == _selectedIndex) {
        backImage = _listCellBackgroundImageSelected;
    } else {
        backImage = _listCellBackgroundImage;
    }
    
    if (backImage) {
        cell.backgroundColor = [UIColor colorWithPatternImage:backImage];
    }
    label.tag = 100;
    label.text = _dataArray[indexPath.row];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = self.font;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_listCellHeight == 0) {
        return _lineHeight;
    }
    return _listCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    self.isOpen = NO;
    if ([_delegate respondsToSelector:@selector(dropdownList:didSelectedIndex:)]) {
        [_delegate dropdownList:self didSelectedIndex:_selectedIndex];
    }
}


- (void)setListBackColor:(UIColor *)color
{
    _dropdownTalbeView.backgroundColor = color;
}

- (void)setRightImage:(UIImage *)rightImage
{
    if (_rightImage != rightImage) {
        _rightImage = nil;
        _rightImage = rightImage;
        self.rightImageView.image = rightImage;
    }
}

- (void)setRightImageSelected:(UIImage *)rightImageSelected
{
    if (_rightImageSelected != rightImageSelected) {
        _rightImageSelected = nil;
        _rightImageSelected = rightImageSelected;
        self.rightImageView.image = nil;
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

- (void)setBackgroundImageSelected:(UIImage *)backgroundImageSelected
{
    if (_backgroundImageSelected != backgroundImageSelected) {
        _backgroundImageSelected = nil;
        _backgroundImageSelected = backgroundImageSelected;
        self.backgroundImageView.image = nil;
    }
}

- (void)setListBackgroundImage:(UIImage *)listBackgroundImage
{
    if (_listBackgroundImage != listBackgroundImage) {
        _listBackgroundImage = nil;
        _listBackgroundImage = listBackgroundImage;
        self.listBackgroundImageView.image = listBackgroundImage;
    }
}

- (UIImageView *)rightImageView
{
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kImageIconSize, kImageIconSize)];
        _rightImageView.userInteractionEnabled = YES;
        [_rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(currentLabelTapGRAction:)]];
        [self addSubview:_rightImageView];
        [self updateSubViews];
    }
    return _rightImageView;
}

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:_currentLabel.bounds];
        
        _currentLabel.backgroundColor = [UIColor clearColor];
        
        [self insertSubview:_backgroundImageView atIndex:0];
        
        [self updateSubViews];
    }
    return _backgroundImageView;
}

- (UIImageView *)listBackgroundImageView
{
    if (!_listBackgroundImageView) {
        _listBackgroundImageView = [[UIImageView alloc] initWithFrame:_dropdownTalbeView.bounds];
        
        _dropdownTalbeView.backgroundColor = [UIColor clearColor];
        
        [self.shadeView insertSubview:_listBackgroundImageView atIndex:0];
        
        [self updateSubViews];
    }
    return _listBackgroundImageView;
}
@end
