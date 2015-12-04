//
//  NormalModeViewController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "NormalModeViewController.h"
#import "DeviceCollectionViewCell.h"
#import "DeviceForUser.h"
#import "WFFVolumnSlider.h"
#import "WFFFollowHandsView.h"

#import "OPManager.h"

@interface NormalModeViewController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *inDeviceTableView;
@property (weak, nonatomic) IBOutlet UITableView *outDeviceTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// 存放所有输入设备(键:设备类型, 值:对应类型的所有设备)
@property (nonatomic, strong) NSDictionary *inDeviceDict;
// 存放所有输出设备(键:设备类型, 值:对应类型的所有设备)
@property (nonatomic, strong) NSDictionary *outDeviceDict;
// 当前选中设备类型下的所有设备列表
@property (nonatomic, strong) NSArray *devicesArray;
// 当前允许连接的输出源设备的indexPath
@property (nonatomic, strong) NSArray *allowConnectedOutDeviceArray;

// 设备信息
@property (weak, nonatomic) IBOutlet UIView *deviceInfoTitleView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceInfoImageView;
@property (weak, nonatomic) IBOutlet UITextView *deviceInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton *deviceInfoOpenButton;
@property (weak, nonatomic) IBOutlet UIButton *deviceInfoCloseButton;
@property (weak, nonatomic) IBOutlet UIView *deviceInfoSliderView;
@property (weak, nonatomic) IBOutlet UIView *deviceInfoOrientationButtonsView;
- (IBAction)deviceInfoOpenButtonAction:(UIButton *)sender;
- (IBAction)deviceInfoCloseButtonAction:(UIButton *)sender;

- (IBAction)deviceInfoOrientationTouchDownAction:(UIButton *)sender;
- (IBAction)deviceInfoOrientationTouchCancelAction:(UIButton *)sender;
- (IBAction)deviceInfoOrientationTouchUpinsideAction:(UIButton *)sender;
- (IBAction)deviceInfoOrientationTouchUpOutsideAction:(UIButton *)sender;


@property (nonatomic, strong) WFFVolumeSlider *volumeSlide;
// 当前选中的设备,为空代表没选中
@property (nonatomic, strong) DeviceForUser *selectedDevice;
// 当前选中的设备类型,为空代表没选中
@property (nonatomic, copy) NSString *selectedDeviceType;


@property (nonatomic, strong) WFFFollowHandsView *currentHandsView;
@end

#define kSlideHeight 50
#define kButtonMargin 10

@implementation NormalModeViewController
static NSString *inDeviceCellIdentifier = @"inDeviceCellIdentifier";
static NSString *outDeviceCellIdentifier = @"outDeviceCellIdentifier";
static NSString *deviceCollectionViewCellIdentifier = @"deviceCollectionViewCellIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    [self.inDeviceTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:inDeviceCellIdentifier];
    [self.outDeviceTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:outDeviceCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DeviceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:deviceCollectionViewCellIdentifier];
    
//    self.inDeviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.outDeviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.volumeSlide = [[WFFVolumeSlider alloc] initWithFrame:self.deviceInfoSliderView.bounds];
    [self.deviceInfoSliderView addSubview:_volumeSlide];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.inDeviceDict = [[Common shareCommon] getInDevicesDict];
    self.outDeviceDict = [[Common shareCommon] getOutDevicesDict];
    [self.inDeviceTableView reloadData];
    [self.outDeviceTableView reloadData];
    // 默认选中输入设备的第一种
    [self.inDeviceTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    // 模拟点击cell
    [self tableView:self.inDeviceTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    
}
// BEGIN 旋转前也会调用这句
// 视图切换时,对子视图的frame进行了设置. 因此子视图的frame如果不再手动改变的话,是恒定值,里面的子视图也就不会按autolaytou来布局
// 也可以代码添加view后,给view添加约束
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.volumeSlide.frame = self.deviceInfoSliderView.bounds;

}
#pragma mark 屏幕旋转
- (void)handleDeviceOrientationDidChange:(NSNotification *)notification
{
    self.volumeSlide.frame = self.deviceInfoSliderView.bounds;
}
// END
#pragma mark - 懒加载
- (NSArray *)devicesArray
{
    if (!_devicesArray) {
        _devicesArray = [NSArray array];
    }
    
    return _devicesArray;
}

#pragma mark - setter
#pragma mark 改变设备类型,变更控制面板.
- (void)setSelectedDeviceType:(NSString *)selectedDeviceType
{
    if (_selectedDeviceType != selectedDeviceType) {
        _selectedDeviceType = nil;
        _selectedDeviceType = selectedDeviceType;
        // 为空.说明点击了设备类型中的设备.不需要变更控制面板
        // [必须return,否则根据nil查找到的设备类型信息为空,所有控制面板就全部隐藏了]
        if (selectedDeviceType == nil) {
            return;
        }
        NSArray *controlersArray = kDeviceTypeInfo(selectedDeviceType)[@"controlCMD"];
        // 判断开关按钮
        if ([controlersArray containsObject:@"oc"]) {
            self.deviceInfoCloseButton.hidden = NO;
            self.deviceInfoOpenButton.hidden = NO;
        } else {
            self.deviceInfoCloseButton.hidden = YES;
            self.deviceInfoOpenButton.hidden = YES;
        }
        // 判断slider
        if ([controlersArray containsObject:@"slider"]) {
            self.deviceInfoSliderView.hidden = NO;
            [self.deviceInfoSliderView.superview bringSubviewToFront:self.deviceInfoSliderView];
        } else {
            self.deviceInfoSliderView.hidden = YES;
        }
        // 判断方向按钮
        if ([controlersArray containsObject:@"orientation"]) {
            self.deviceInfoOrientationButtonsView.hidden = NO;
            [self.deviceInfoOrientationButtonsView.superview bringSubviewToFront:self.deviceInfoOrientationButtonsView];
        } else {
            self.deviceInfoOrientationButtonsView.hidden = YES;
        }
    }
}

#pragma mark - 选择设备类型
- (void)chooseDeviceType:(NSString *)deviceType
{
    self.selectedDeviceType = deviceType;
    self.selectedDevice = nil;
    [self updateUIOfDeviceInfoView];
}
#pragma mark - 选择设备
- (void)chooseDevice:(DeviceForUser *)device
{
    self.selectedDevice = device;
    self.selectedDeviceType = nil;
    [self updateUIOfDeviceInfoView];
}


#pragma mark - 更新设备详情界面
- (void)updateUIOfDeviceInfoView
{
    if (self.selectedDeviceType && !self.selectedDevice) {
        NSDictionary *dict = kDeviceTypeInfo(self.selectedDeviceType);
        
        //    self.deviceInfoTitleView = nil;
        self.deviceInfoImageView.image = [UIImage imageNamed:dict[@"imageName"]];
        self.deviceInfoTextView.text = dict[@"name"];
    } else if (self.selectedDevice && !self.selectedDeviceType){
        //    self.deviceInfoTitleView = nil;
        self.deviceInfoImageView.image = [UIImage imageNamed:self.selectedDevice.imageName];
        self.deviceInfoTextView.text = self.selectedDevice.UEQP_Name;
    } else {
        kLog(@"无法识别当前选中的是设备还是设备类型");
        self.deviceInfoImageView.image = nil;
        self.deviceInfoTextView.text = nil;
    }
}
#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.inDeviceTableView) {
        return self.inDeviceDict.allKeys.count;
    }
    return self.outDeviceDict.allKeys.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = tableView == self.inDeviceTableView ? self.inDeviceDict : self.outDeviceDict;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(tableView == self.inDeviceTableView ? inDeviceCellIdentifier : outDeviceCellIdentifier) forIndexPath:indexPath];
    
    
    NSString *deviceType = dict.allKeys[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:kDeviceTypeInfo(deviceType)[@"imageName"]];
    cell.textLabel.text = kDeviceTypeInfo(deviceType)[@"name"];
    
    
    if (tableView == self.outDeviceTableView) { // 当前输出源是否可以与当前选中的输入源连接
        if ([self.allowConnectedOutDeviceArray containsObject:indexPath]) {
            cell.layer.borderWidth = 1;
            cell.layer.borderColor = [UIColor redColor].CGColor;
        } else {
            cell.layer.borderWidth = 0;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = tableView == self.inDeviceTableView ? self.inDeviceDict : self.outDeviceDict;
    NSString *deviceType = dict.allKeys[indexPath.row];
    // 刷新设备详情界面
    [self chooseDeviceType:deviceType];
    
    if (tableView == self.inDeviceTableView) {// 选择的输入源 判断是否输出源要高亮
        self.devicesArray = [self.inDeviceDict objectForKey:self.inDeviceDict.allKeys[indexPath.row]];
        // 选中输入源后,更新当前允许选中的输出源列表
        self.allowConnectedOutDeviceArray = [self getIndexPathOfAllowConnectedOutDevicesWithInDeviceType:deviceType];
        // 刷新后,默认取消选中状态了
        [self.outDeviceTableView reloadData];
    } else { // 选中输出源 输入源全部不选中
        self.devicesArray = [self.outDeviceDict objectForKey:self.outDeviceDict.allKeys[indexPath.row]];
        // 选中输出源时,允许连接的设备为空.[连接是由I2O]
        self.allowConnectedOutDeviceArray = nil;
        
        [self didUnSignAllowConnectedOutDevice];
        // 输入源取消选中
        [self.inDeviceTableView deselectRowAtIndexPath:[self.inDeviceTableView indexPathForSelectedRow] animated:YES];
    }
    [self.collectionView reloadData];

}

#pragma mark - 根据输入源设备类型,返回允许连接的输出源的NSIndexPath
- (NSArray *)getIndexPathOfAllowConnectedOutDevicesWithInDeviceType:(NSString *)inDeviceType
{
    NSMutableArray *indexPathsArray = [NSMutableArray array];
    NSArray *allowConnectedOutDevicesArray = [kDeviceTypeInfo(inDeviceType)[@"soundConnectedType"] arrayByAddingObjectsFromArray:kDeviceTypeInfo(inDeviceType)[@"videoConnectedType"]];
    for (NSString *outDeviceType in self.outDeviceDict.allKeys) {
        if ([allowConnectedOutDevicesArray containsObject:outDeviceType]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.outDeviceDict.allKeys indexOfObject:outDeviceType] inSection:0];
            [indexPathsArray addObject:indexPath];
        }
    }
    return indexPathsArray;
}

#pragma mark - 取消输出源类型列表中的所有可连接标识(当点击输出设备列表时)
- (void)didUnSignAllowConnectedOutDevice
{
    for (UIView *view in [self.outDeviceTableView.subviews.firstObject subviews]) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            view.layer.borderWidth = 0;
        }
    }
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.devicesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceCollectionViewCellIdentifier forIndexPath:indexPath];
    
    DeviceForUser *model = self.devicesArray[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:model.imageName];
    cell.imageView.tag = indexPath.row;
    cell.imageView.userInteractionEnabled = YES;
    cell.imageView.exclusiveTouch = YES;
    if (cell.imageView.gestureRecognizers.count == 0) {
        // 手势事件中,根据view的tag来决定选中的哪一个设备.
        [cell.imageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deviceImageViewLongPressGRAction:)]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceForUser *model = self.devicesArray[indexPath.row];
    [self chooseDevice:model];
    kLog(@"选中的设备ID: %ld %@", (long)model.AutoID,  kDeviceTypeInfo(model.UEQP_Type)[@"name"]);
    
}

#pragma mark - 设备列表中的设备长按事件
- (void)deviceImageViewLongPressGRAction:(UILongPressGestureRecognizer *)sender
{
    NSIndexPath *indexPath = nil;
    DeviceCollectionViewCell *cell = nil;
    DeviceForUser *model = nil;
    
    static CGRect oriRect;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            
            // 刚触摸的时候才赋值,移动过程中进来后,indexPath对应的cell已经删除,若再执行下面语句就会溢出
            indexPath = [NSIndexPath indexPathForRow:sender.view.tag inSection:0];
            cell = (DeviceCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            model = self.devicesArray[indexPath.row];
            
            // 长按开始后,直接默认选中
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
            
            // 显示跟随的view
            self.currentHandsView = [WFFFollowHandsView followHandsViewWithWidth:kFollowHandsViewOfDeviceWidth1 height:kFollowHandsViewOfDeviceHeight1 deviceCell:cell device:model onView:self.view];
            oriRect = self.currentHandsView.frame;
            // 隐藏设备列表
            // 开始移动
            [self.currentHandsView beginMoveByGR:sender];
            break;
        case UIGestureRecognizerStateChanged:
            [self.currentHandsView moveByGR:sender];
            break;
        case UIGestureRecognizerStatePossible:
            
            break;
        default: // UIGestureRecognizerStateEnded UIGestureRecognizerStateFailed UIGestureRecognizerStateCancelled
            [self.currentHandsView endMoveByGR:sender];
            for (NSIndexPath *indexPath in self.allowConnectedOutDeviceArray) {
                DeviceCollectionViewCell *cell = (DeviceCollectionViewCell *)[self.outDeviceTableView cellForRowAtIndexPath:indexPath];
                CGRect cellRect = [self.outDeviceTableView.subviews.firstObject convertRect:cell.frame toView:self.view];
                if (CGRectContainsPoint(cellRect, self.currentHandsView.center)) { // 如果放到某个区间内
                    // 1连接多
                    DeviceForUser *current = [[Common shareCommon] getActualDeviceWithID:self.currentHandsView.tag];
                    kDeviceBatchConn(@[current], self.outDeviceDict[self.outDeviceDict.allKeys[indexPath.row]], ^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
                        kLog(@"输入源ID:%@ 与 %ld个输出源连接%@", [devices.firstObject UEQP_ID], (long)otherDevices.count, isSuccess ? @"成功" : @"失败");
                    });
                }
            }
            [self.currentHandsView removeFromSuperview];
            self.currentHandsView = nil;
            break;
    }
}

- (IBAction)deviceInfoOpenButtonAction:(UIButton *)sender {
    if (self.selectedDevice) {
        kDeviceOpen(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 打开%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    } else { // 批量操作
        kDeviceBatchOpen(self.devicesArray, ^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
            if (isSuccess) {
                kLog(@"类型:%@ %ld个设备 批量打开%@",kDeviceTypeInfo([devices.firstObject UEQP_Type])[@"name"], (long)devices.count, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    }
}

- (IBAction)deviceInfoCloseButtonAction:(UIButton *)sender {
    if (self.selectedDevice) {
        kDeviceClose(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 关闭%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
            
        });
    } else { // 批量操作
        kDeviceBatchClose(self.devicesArray, ^(BOOL isSuccess, NSInteger cmdNumber, NSArray *devices, NSArray *otherDevices) {
            if (isSuccess) {
                kLog(@"类型:%@ %ld个设备 批量关闭%@",kDeviceTypeInfo([devices.firstObject UEQP_Type])[@"name"], (long)devices.count, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
            
        });
    }
}

- (IBAction)deviceInfoOrientationTouchDownAction:(UIButton *)sender {
    if (self.selectedDevice) {
        kDeviceStartPTZ(self.selectedDevice, sender.tag, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 开始调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
            
        });
    } else {
        kLog(@"云台无法批量控制");
    }
}

- (IBAction)deviceInfoOrientationTouchCancelAction:(UIButton *)sender {
    if (self.selectedDevice) {
        kDeviceStopPTZ(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 停止调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
            
        });
    }
}

- (IBAction)deviceInfoOrientationTouchUpinsideAction:(UIButton *)sender {
    if (self.selectedDevice) {
        kDeviceStopPTZ(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 停止调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    }
}

- (IBAction)deviceInfoOrientationTouchUpOutsideAction:(UIButton *)sender {
    if (self.selectedDevice) {
        kDeviceStopPTZ(self.selectedDevice, ^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
            if (isSuccess) {
                kLog(@"命令编号%ld 操作设备类型:%@ 设备ID:%@ 停止调整方向%@",(long)cmdNumber, kDeviceTypeInfo(deviceForUser.UEQP_Type)[@"name"], deviceForUser.UEQP_ID, isSuccess ? @"成功" : @"失败");
            } else {
                [self showAlertControllerWithTitle:@"网络连接故障,请重试!"];
            }
        });
    }
}

@end
