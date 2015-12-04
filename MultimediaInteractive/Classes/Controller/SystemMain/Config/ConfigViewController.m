//
//  ConfigViewController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/29.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "ConfigViewController.h"
#import "Area.h"
#import "AreaConfig.h"
#import "DetailOfAreaConfig.h"
#import "DeviceForUser.h"
#import "OPManager.h"
@interface ConfigViewController () <UITableViewDataSource, UITableViewDelegate>

// 当前配置
@property (nonatomic, strong) NSMutableArray *currentConfigArray;

@property (nonatomic, assign) NSInteger selectedIndex;
// 选中的配置详情
@property (nonatomic, strong) NSMutableArray *detailOfConfigArray;
// 所有配置
@property (nonatomic, strong) NSMutableArray *areaConfigArray;

@property (weak, nonatomic) IBOutlet UITableView *areaConfigTableView;
@property (weak, nonatomic) IBOutlet UITableView *detailOfConfigTableView;
- (IBAction)addButtonAction:(UIButton *)sender;
- (IBAction)deleteButtonAction:(UIButton *)sender;
- (IBAction)saveButtonAction:(UIButton *)sender;
- (IBAction)applyButtonAction:(UIButton *)sender;

@end


static NSString *areaConfigCellIdentifier = @"areaConfig";
static NSString *detailOfConfigCellIdentifier = @"detailOfConfig";

@implementation ConfigViewController
#pragma mark - 生命周期函数
- (void)viewDidLoad {
    [super viewDidLoad];
    self.areaConfigTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.detailOfConfigTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.areaConfigTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:areaConfigCellIdentifier];
    [self.detailOfConfigTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:detailOfConfigCellIdentifier];
    
    [self updateAreaConfigs];
    
    self.selectedIndex = 0;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateCurrentConfig];
    
    // 若选中的是当前配置,则刷新
    if (self.selectedIndex == 0) {
        [self.detailOfConfigTableView reloadData];
    }
    
    
}
#pragma mark - 从内存中获取当前配置
- (void)updateCurrentConfig
{
    // 重新获取当前配置
    [self.currentConfigArray removeAllObjects];
    for (DeviceForUser *model in kCurrentActualDeviceArray) {
        if (model.currentConfigs.count > 0) {
            [self.currentConfigArray addObject:model];
        }
    }
}

#pragma mark - 从本地数据库获取所有配置列表
- (void)updateAreaConfigs
{
    
    self.areaConfigArray = [NSMutableArray arrayWithArray:kAreaConfigArray];
    [self.areaConfigTableView reloadData];
}

#pragma mark - setter
- (void)setAreaConfigArray:(NSMutableArray *)areaConfigArray
{
    if (_areaConfigArray != areaConfigArray) {
        _areaConfigArray = nil;
        _areaConfigArray = areaConfigArray;
        
        NSArray *array = @[@"全部关闭", @"全部打开", @"当前配置"];
        for (NSString *str in array) {
            AreaConfig *areaConfig = [AreaConfig new];
            areaConfig.areaID = kCurrentArea.AreaID;
            areaConfig.configName = str;
            [_areaConfigArray insertObject:areaConfig atIndex:0];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if (selectedIndex == 0) {
        [self updateCurrentConfig];
        self.detailOfConfigArray = self.currentConfigArray;
    } else if (selectedIndex == 1 || selectedIndex == 2) {
        self.detailOfConfigArray = nil;
    } else {
        self.detailOfConfigArray = [NSMutableArray array];
        NSString *configName = [self.areaConfigArray[selectedIndex] configName];
        NSArray *array = [[DBHelper shareDBHelper] getDetailWithConfigName:configName];
        for (DetailOfAreaConfig *model in array) {
            DeviceForUser *device = [[Common shareCommon] getDeviceWithUEQP_ID:model.deviceID];
            NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:model.configData];
            device.localConfig = dict;
            [self.detailOfConfigArray addObject:device];
        }
    }
    [self.areaConfigTableView reloadData];
    [self.detailOfConfigTableView reloadData];
}

#pragma mark Lazy Loading
- (NSMutableArray *)currentConfigArray
{
    if (!_currentConfigArray) {
        _currentConfigArray = [NSMutableArray array];
    }
    return _currentConfigArray;
}


#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.detailOfConfigTableView) {
        if (self.selectedIndex == 1 || self.selectedIndex == 2) {
            return 1;
        }
        return self.detailOfConfigArray.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.detailOfConfigTableView) {
        DeviceForUser *model = self.detailOfConfigArray[section];
        if (self.selectedIndex == 0) { // 当前
            return model.currentConfigs.count;
        }
        return model.localConfig.count;
    } else {
        return self.areaConfigArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.detailOfConfigTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailOfConfigCellIdentifier forIndexPath:indexPath];

        DeviceForUser *model = self.detailOfConfigArray[indexPath.section];
        NSDictionary *configItems = self.selectedIndex == 0 ? model.currentConfigs : model.localConfig;
        NSString *key = configItems.allKeys[indexPath.row];
        
        if ([key isEqualToString:kConfigOCKey]) {
            DeviceOCState ocState = [configItems[key] intValue];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", ocState == DeviceOpen ? @"打开" : @"关闭"];
        } else if ([key isEqualToString:kConfigSetValueKey]) {
            NSString *value = configItems[key];
            cell.textLabel.text = [NSString stringWithFormat:@"值:%@", value];
        } else if ([key isEqualToString:kConfigConnKey]) {
            NSString *otherID = configItems[key];
            DeviceForUser *otherDevice = [[Common shareCommon] getDeviceWithUEQP_ID:otherID];
            cell.textLabel.text = [NSString stringWithFormat:@"连接 - 设备类型:%@ 名称:%@", kDeviceTypeInfo(otherDevice.UEQP_Type)[@"name"], otherDevice.UEQP_Name];
        } else if ([key isEqualToString:kConfigChangeChannel]) {
            cell.textLabel.text = [NSString stringWithFormat:@"频道 %@", configItems[key]];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:areaConfigCellIdentifier forIndexPath:indexPath];
    AreaConfig *model = self.areaConfigArray[indexPath.row];
    cell.textLabel.text = model.configName;
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (self.selectedIndex == indexPath.row) {
        cell.backgroundColorFromUIImage = [UIImage imageNamed:@"cellBgForSelected"];
    } else  if (indexPath.row < 3){
        cell.backgroundColorFromUIImage = [UIImage imageNamed:@"cellBgForDefault"];
    } else {
        cell.backgroundColorFromUIImage = [UIImage imageNamed:@"cellBgForCustom"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.detailOfConfigTableView) {

        return 40;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.detailOfConfigTableView) {
        return ;
    }
    self.selectedIndex = indexPath.row;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView == self.detailOfConfigTableView) {
        return 0.1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.detailOfConfigTableView) {
        return 40;
    }
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.detailOfConfigTableView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 50)];
        [view addSubview:label];
        if (self.selectedIndex == 1) {
            label.text = @"打开所有设备";
        } else if (self.selectedIndex == 2) {
            label.text = @"关闭所有设备";
        } else {
            DeviceForUser *model = self.detailOfConfigArray[section];
            label.text = [NSString stringWithFormat:@"%@", model];
        }
        view.backgroundColor = [UIColor colorFromHexRGB:@"141414"];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor grayColor];
        return view;
    }
    return nil;
}

#pragma mark - 应用配置
- (void)applyConfig
{
    if (self.selectedIndex == 1 || self.selectedIndex == 2) {
        CMDType cmdType = (CMDType)self.selectedIndex;// 1打开  2关闭
        if (cmdType == CMDTypeOpen) {
            [[OPManager shareOPManager] deviceBatchOpenWithDevices:kCurrentActualDeviceArray resultBlock:nil];
        } else {
            [[OPManager shareOPManager] deviceBatchCloseWithDevices:kCurrentActualDeviceArray resultBlock:nil];
        }
    } else { // 应用之前保存的配置 - 选中保存的配置后,detailOfConfigArray内的值即为对应的配置详情
        // 先清除所有信息
        [[Common shareCommon] clearConfigOfAllDevice];
        // 根据配置信息开始应用
        for (DeviceForUser *model in self.detailOfConfigArray) {// 输出设备.
            // 回调block
            // 设备先开关后,再执行
            void (^afterOCBlock)()  = ^() {
                // 等待开启之后再执行
                sleep(3);
                [model.localConfig enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([key isEqualToString:kConfigOCKey]) {
                        // 前面先执行了
                        //                    if ([obj intValue] == DeviceOpen) { // 打开
                        //                        [[OPManager shareOPManager] deviceOpenWithDevice:model resultBlock:nil];
                        //                    } else {
                        //                        [[OPManager shareOPManager] deviceCloseWithDevice:model resultBlock:nil];
                        //                    }
                    } else if ([key isEqualToString:kConfigSetValueKey]) {
                        [[OPManager shareOPManager] deviceSetValueWithDevice:model deviceValue:obj resultBlock:nil];
                    } else if ([key isEqualToString:kConfigConnKey]) {
                        // 和输出设备连接的输入设备ID
                        NSString *UEQP_ID = obj;
                        // 输入设备
                        DeviceForUser *device = [[Common shareCommon] getDeviceWithUEQP_ID:UEQP_ID];
                        // 连接的时候,device为输入源 other为输出源
                        [[OPManager shareOPManager] deviceConnWithDevice:device otherDevice:model resultBlock:nil];
                    } else if ([key isEqualToString:kConfigChangeChannel]) {
                        [[OPManager shareOPManager] deviceChangeChannelWtihDevice:model channel:obj resultBlock:nil];
                    }
                }];
            };
            
            // 先执行打开关闭操作
            if ([model.localConfig.allKeys containsObject:kConfigOCKey]) { // 设备配置内有开关操作, 就先执行打开操作.再执行其他
                if ([model.localConfig[kConfigOCKey] intValue] == DeviceOpen) { // 打开
                    [[OPManager shareOPManager] deviceOpenWithDevice:model resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
                        if ([NSThread currentThread].isMainThread) { // 是主线程
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{ // 主线程,里面的休眠动作会直接使主线程假死, 需要切换线程
                                afterOCBlock();
                            });
                        } else {
                            afterOCBlock();
                        }
                    }];
                } else {
                    // 包含关闭, 就不执行任何操作 -- 设备关闭后,再发送其他命令也没有作用
//                    [[OPManager shareOPManager] deviceCloseWithDevice:model resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, DeviceForUser *deviceForUser, DeviceForUser *otherDeviceForUser) {
//                        afterOCBlock();
//                    }];
                }
            } else { // 设备没有打开操作,就直接执行
                // 设备开启后,要延迟一段时间才能操作.
                if ([NSThread currentThread].isMainThread) { // 是主线程
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{ // 主线程,里面的休眠动作会直接使主线程假死, 需要切换线程
                        afterOCBlock();
                    });
                } else {
                    afterOCBlock();
                }
                
            }
        }
        //
        
    }
}

#pragma mark - 保存配置信息[添加或替换]
- (void)insertConfigWithArray:(NSArray *)array configName:(NSString *)configName isReplace:(BOOL)isReplace
{
    // 根据当前配置构建模型数组以写入到数据库
    NSMutableArray *detailForSave = [NSMutableArray array];
    for (DeviceForUser *model in array) {
        DetailOfAreaConfig *detail = [DetailOfAreaConfig new];
        detail.configName = configName;
        detail.deviceID = model.UEQP_ID;
        detail.configData = [NSKeyedArchiver archivedDataWithRootObject:model.currentConfigs];
        [detailForSave addObject:detail];
    }
    // 保存到数据库
    [[DBHelper shareDBHelper] insertDetail:detailForSave intoConfigWithName:configName isReplace:isReplace];

   
    if (!isReplace) {
        // 重新从数据库获取
        [self updateAreaConfigs];
        // 选中插入行
        self.selectedIndex = self.areaConfigArray.count - 1;
    } else {
        self.selectedIndex = self.selectedIndex;
    }
    
}

#pragma mark - 按钮点击事件
- (IBAction)addButtonAction:(UIButton *)sender {
    
    if (self.currentConfigArray.count > 0) {
         __weak typeof(self) weakSelf = self;
        [self showAlertControllerWithTitle:@"请输入配置名" hasTextField:YES okHandle:^(NSString *returnText) {
            //
            NSString *configName = returnText;
            [weakSelf insertConfigWithArray:self.currentConfigArray configName:configName isReplace:NO];
            
        } cancelHandle:^{
            
        }];
    } else {
        [self showAlertControllerWithTitle:@"当前没有可添加配置信息" hasTextField:NO okHandle:nil cancelHandle:nil];
    }
}

- (IBAction)deleteButtonAction:(UIButton *)sender {
    if (self.selectedIndex < 3) {
        [self showAlertControllerWithTitle:@"预设配置无法删除" hasTextField:NO okHandle:nil cancelHandle:nil];
    } else {
        NSString *currentConfigName = [self.areaConfigArray[self.selectedIndex] configName];
        __weak typeof(self) weakSelf = self;
        [self showAlertControllerWithTitle:[NSString stringWithFormat:@"确认要删除选中配置项: %@ ?", currentConfigName] hasTextField:NO okHandle:^(NSString *returnText) {
            // 删除配置
            [[DBHelper shareDBHelper] deleteConfigWithName:currentConfigName];
            // 更新配置列表
            [weakSelf updateAreaConfigs];
            // 选中第一行[当前配置]
            weakSelf.selectedIndex = 0;
        } cancelHandle:^{
            
        }];
    }
}

- (IBAction)saveButtonAction:(UIButton *)sender {
    if (self.selectedIndex < 3) {
        [self showAlertControllerWithTitle:@"预设配置无法替换" hasTextField:NO okHandle:nil cancelHandle:nil];
    } else {
        NSString *currentConfigName = [self.areaConfigArray[self.selectedIndex] configName];
        __weak typeof(self) weakSelf = self;
        [self showAlertControllerWithTitle:[NSString stringWithFormat:@"确认要以当前配置替换选中配置项: %@ ?", currentConfigName] hasTextField:NO okHandle:^(NSString *returnText) {
            [weakSelf insertConfigWithArray:self.currentConfigArray configName:currentConfigName isReplace:YES];
        } cancelHandle:^{
            
        }];
    }
}

- (IBAction)applyButtonAction:(UIButton *)sender {
    if (self.selectedIndex == 0) {
        [self showAlertControllerWithTitle:@"请选择要应用的配置" hasTextField:NO okHandle:nil cancelHandle:nil];
    } else {
        NSString *currentConfigName = [self.areaConfigArray[self.selectedIndex] configName];
        __weak typeof(self) weakSelf = self;
        [self showAlertControllerWithTitle:[NSString stringWithFormat:@"确认应用选中的配置项 %@ ?", currentConfigName] hasTextField:NO okHandle:^(NSString *returnText) {
            
            [weakSelf applyConfig];
            
        } cancelHandle:^{
            
        }];
    }
}
@end
