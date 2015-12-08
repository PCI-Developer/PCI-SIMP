//
//  SystemMainViewController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "SystemMainViewController.h"
#import "WFFDropdownList.h"
#import "SHStripeMenuExecuter.h"
#import "NormalModeViewController.h"
#import "ActualModeViewController.h"
#import "LogInfoViewController.h"
#import "ConfigViewController.h"
#import "SHMenuItem.h"
#import "Reachability.h"
#import "Area.h"


#define kDeviceBatteryState ([UIDevice currentDevice].batteryState)
#define kDeviceBatteryLevel ([UIDevice currentDevice].batteryLevel)


@interface SystemMainViewController ()<WFFDropdownListDelegate, SHStripeMenuActionDelegate>
// 选择系统的下拉列表
@property (weak, nonatomic) IBOutlet WFFDropdownList *dropDownList;

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

// 存放子视图的字典,键为对应的索引下标
@property (nonatomic, strong) NSMutableDictionary *viewControllersDict;

// 当前选中的菜单项
@property (nonatomic, copy) NSString *selectedVC;

// 上一次选中的菜单项
@property (nonatomic, copy) NSString *lastVC;
// 当前展示的子vc的view
@property (nonatomic, strong) UIView *currentView;


@property (nonatomic, strong) SHStripeMenuExecuter *menu;

@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *batteryBgWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImageView;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (nonatomic, strong) Reachability *reachability;

// 时间同步
@property (nonatomic, strong) NSTimer *timer;

/**
 *  当选中同一项的时候,根据此字段决定是否重载界面
 *  界面的加载是在selectedVC的setter中实现的.当切换区域的时候,手动调用setter方法进行重载.此时需要设置为YES;
 */
@property (nonatomic, copy) NSMutableDictionary *notNeedUpdateDict;
@end

#define kBatteryBgWidthOfFull (-10)
#define kBatteryBgWidthOfEmpty (-32)

@implementation SystemMainViewController


#pragma mark - 懒加载
- (NSMutableDictionary *)viewControllersDict
{
    if (!_viewControllersDict) {
        _viewControllersDict = [NSMutableDictionary dictionary];
    }
    return _viewControllersDict;
}

#pragma mark - 生命周期函数
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notNeedUpdateDict = [NSMutableDictionary dictionary];
    self.menu = [SHStripeMenuExecuter new];
    [self.menu setupToParentView:self withLineView:({
        UIImageView *imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"showMenu"]];
        imageView.frame = CGRectMake(0, 0, 30, 60);
        imageView.userInteractionEnabled = YES;
        imageView;
    })];
    
    // 电池通知
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceBatteryLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceBatteryStateChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    // 服务器连接通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedStateChanged:) name:NotificationDidConnectedStateChange object:nil];
    
    self.selectedVC = @"ActualModeViewController";

    // 网络变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.reachability = [Reachability reachabilityForLocalWiFi];
    [self.reachability startNotifier];
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationDidConnectedStateChange object:nil];

    
    self.dropDownList.dataArray = [self getAreasName];
    _dropDownList.delegate = self;
    _dropDownList.selectedIndex = 0;
    _dropDownList.maxCountForShow = 3;
    _dropDownList.textColor = [UIColor whiteColor];
    _dropDownList.font = [UIFont systemFontOfSize:25];
    
    [self updateBattery];
    [self updateWifi];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeMonitoring:) userInfo:nil repeats:YES];
        // 时间
    self.timeLabel.text = [NSString stringOnlyTimeWithDate:[NSDate date] dateFormat:@"HH:mm"];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    // 必须释放,否则timer的事件中引用了self. 导致死锁无法释放
    self.timer = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    kLog(@"system dealloc");
}


// BEGIN
// 视图切换时,对子视图的frame进行了设置. 因此子视图的frame如果不再手动改变的话,是恒定值,里面的子视图也就不会按autolaytou来布局
// 也可以代码添加view后,给view添加约束
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.currentView.frame = self.contentView.bounds;
    
    [self.dropDownList layoutIfNeeded];
    [self.dropDownList updateSubViews];
}

#pragma mark - 时间同步
/**
 *  时间同步
 */
- (void)timeMonitoring:(NSTimer *)timer
{
//    kLog(@"%@", [NSThread currentThread]);
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    __weak __typeof(self) weakSelf = self;
//    static BOOL hasMaoHao = YES;
//    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 1);
//    dispatch_source_set_event_handler(timer, ^{
//        hasMaoHao = !hasMaoHao;
//        dispatch_async(dispatch_get_main_queue(), ^{

//        self.timeLabel.text = [NSString stringOnlyTimeWithDate:[NSDate date] dateFormat:[NSString stringWithFormat:@"HH%@mm", hasMaoHao ? @":" : @" "]];
    self.timeLabel.text = [NSString stringOnlyTimeWithDate:[NSDate date] dateFormat:@"HH:mm"];
//        });
//        
//    });
//    dispatch_resume(timer);
}

#pragma mark - 通知
#pragma mark 设备电池
- (void)deviceBatteryLevelChanged:(id)obj
{
    //    kLog(@"当前电量%.2f", kDeviceBatteryLevel * 100);
    [self updateBattery];
}

- (void)deviceBatteryStateChanged:(id)obj
{
    [self updateBattery];
    // 0:未知 1: 没充电 2:充电 3:充满
    // kLog(@"电池状态 %ld", kDeviceBatteryState);
}

- (void)connectedStateChanged:(NSNotification *)sender
{
    if ([SocketManager shareSocketManager].state == SocketStateDisConnected) {
        [self.indicatorImageView setHighlighted:YES];
//        if (![KVNProgress isVisible]) {
//            kLog(@"与服务器断开连接");
//            [KVNProgress showWithStatus:@"正在连接服务器..."];
//        }
    } else {
        [self.indicatorImageView setHighlighted:NO];
//        if ([KVNProgress isVisible]) {
//            kLog(@"与服务器成功连接");
//            [KVNProgress dismiss];
//        }
    }
}

- (void)wifiStatusChanged:(NSNotification *)sender
{
    [self updateWifi];
}

#pragma mark 屏幕旋转
- (void)handleDeviceOrientationDidChange:(NSNotification *)notification
{
    self.currentView.frame = self.contentView.bounds;
    
    [self.dropDownList layoutIfNeeded];
    [self.dropDownList updateSubViews];
}
// END

#pragma mark - SHSTripeMenuExecuterDelegate
- (void)stripeMenuItemSelected:(SHMenuItem *)item
{
    if ([item.gotoVC length] > 0) {
        self.selectedVC = item.gotoVC;
    } else {
        if (item.function) {
            SEL sel = NSSelectorFromString(item.function);
            // 改BuildSetting的ENABLE_STRICT_OBJC_MSGSEND字段为NO才可使用
            objc_msgSend(self, sel);
        }
    }
}

- (void)logout
{
    [[Common shareCommon] logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - 更新电池状态
- (void)updateBattery
{
    NSString *imageName = nil;
    CGFloat widthConstraint;
    switch (kDeviceBatteryState) {
        case UIDeviceBatteryStateUnknown:
            imageName = @"batteryUnknow";
            widthConstraint = kBatteryBgWidthOfEmpty;
            break;
        case UIDeviceBatteryStateCharging:
            imageName = @"batteryCharging";
            widthConstraint = kBatteryBgWidthOfEmpty;
            break;
        case UIDeviceBatteryStateFull:
            imageName = @"batteryFull";
            widthConstraint = kBatteryBgWidthOfEmpty;
            break;
        case UIDeviceBatteryStateUnplugged:
            imageName = @"batteryEmpty";
            widthConstraint = (kBatteryBgWidthOfFull - kBatteryBgWidthOfEmpty) * kDeviceBatteryLevel + kBatteryBgWidthOfEmpty;
            break;
    }
    
    self.batteryImageView.image = [UIImage imageNamed:imageName];
    self.batteryLevelLabel.text = [NSString stringWithFormat:@"%.0f%%", kDeviceBatteryLevel * 100];
    self.batteryBgWidthConstraint.constant = widthConstraint;
}


#pragma mark 更新wifi状态
- (void)updateWifi
{
    if ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus != ReachableViaWiFi) {
        [self.wifiImageView setHighlighted:NO];
        if ([SocketManager shareSocketManager].state == SocketStateConnected) {
            [[SocketManager shareSocketManager] breakTcpSocket];
        }
    } else {
        if ([SocketManager shareSocketManager].state == SocketStateDisConnected) {
            
            [[SocketManager shareSocketManager] createTcpSocket];
        }
        [self.wifiImageView setHighlighted:YES];
    }
}

#pragma mark - WFFDropdownListDelegate
- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex
{
    [self gotoAreaWithIndex:selectedIndex];
}

#pragma mark - 跳转到指定区域

- (void)gotoAreaWithIndex:(NSInteger)index
{
    [[Common shareCommon] changeAreaWithIndex:index];
    [self.viewControllersDict removeAllObjects];
    
    /**
     *  标记为需要重载
     */
    [self.notNeedUpdateDict removeAllObjects];
    // 切换区域.移除所有
    for (UIViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
    }
    
    // 重新加载子页面
    self.selectedVC = _selectedVC;
}
#pragma mark - 获取所有区域名称
- (NSArray *)getAreasName
{
    NSMutableArray *array = [NSMutableArray array];
    for (Area *area in kAllAreas) {
        [array addObject:area.AreaName];
    }
    return array;
}


#pragma mark - setter
- (void)setCurrentView:(UIView *)currentView
{
    if (_currentView != currentView) {
        // 从父视图移除,防止父视图引用,导致不会释放.防止内存泄漏
        if (_currentView) {
            [_currentView removeFromSuperview];
        }
        
        [_contentView addSubview:currentView];
        
        _currentView = nil;
        _currentView = currentView;
    }
}

- (void)setSelectedVC:(NSString *)selectedVC
{
    if (_selectedVC == selectedVC) {
        if (self.notNeedUpdateDict[selectedVC] && [self.notNeedUpdateDict[selectedVC] boolValue]) {
            return;
        } else { // 需要重载,重载后就不需要,因此设置为YES
            self.notNeedUpdateDict[selectedVC] = @(YES);
        }
    }
    
    self.lastVC = _selectedVC;
    _selectedVC = selectedVC;
    
    
    UIViewController *vc = self.viewControllersDict[selectedVC];
    
    // 类工厂创建vc
    if (!vc) {
        vc = [((UIViewController *)[NSClassFromString(_selectedVC) alloc]) initWithNibName:_selectedVC bundle:nil];
        //        [self addChildViewController:vc];//加进去后,更改区域时也必须删掉,否则随着区域切换次数的增加,内存会无穷增加.因此直接略去
        [self.viewControllersDict setObject:vc forKey:_selectedVC];
        vc.view.frame = _contentView.bounds;
    }
    
    self.currentView = vc.view;
}

@end
