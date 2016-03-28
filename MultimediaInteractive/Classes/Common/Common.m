//
//  Common.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "Common.h"
#import "User.h"
#import "Area.h"
#import "DeviceForUser.h"
#import "LogInfo.h"
#import "Process.h"
@interface Common () {

}

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, strong) Area *currentArea;

@property (nonatomic, strong) NSMutableArray *allAreasArray;

@property (nonatomic, strong) NSMutableDictionary *allDevicesDict;// 面向用户的设备  键:areaID 值:模型数组

@property (nonatomic, strong) NSDictionary *deviceTypeDict;

@property (nonatomic, strong) NSMutableDictionary *allProcessDict;// 键:areaID 值:process模型数组

@property (nonatomic, strong) NSMutableArray *commonDeviceArray; // 公共设备


#pragma mark - 实景图
@property (nonatomic, strong) UIImage *actualImage;

@property (nonatomic, strong) NSMutableDictionary *logDict; // 日志信息 键:命令编号 值:LogInfo



@end

@implementation Common
#pragma mark - 单例
kSingleTon_M(Common)

// 初始化测试数据
- (instancetype)init
{
    if (self = [super init]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kLocalUserKey]) {
            self.currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kLocalUserKey]];
        }
        self.logDict = [NSMutableDictionary dictionary];
        self.hasLogin = NO;
        self.isDemo = NO;
        
    }
    return self;
}

#pragma mark - 方法
- (User *)currentUser
{
    return _currentUser;
}

- (NSString *)userName
{
    return _currentUser.name;
}


- (Area *)currentArea
{
    return _currentArea;
}

- (NSString *)areaName
{
    return _currentArea.AreaName;
}

#pragma mark - 获取当前区域所有设备类型
- (NSArray *)getAllDeviceTypes
{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (DeviceForUser *model in self.allDevicesDict[self.currentArea.AreaID]) {
        if (![resultArray containsObject:model.UEQP_Type]) {
            [resultArray addObject:model.UEQP_Type];
        }
    }
    return resultArray;
}

#pragma mark - 获取当前区域的输入源设备
- (NSDictionary *)getInDevicesDict
{
    return [self getDevicesDictForTypeWithKey:@"inOrOut" value:@"in"];
}

#pragma mark - 获取当前区域的输出源设备
- (NSDictionary *)getOutDevicesDict
{
    return [self getDevicesDictForTypeWithKey:@"inOrOut" value:@"out"];
}
#pragma mark - 获取当前区域的所有实体设备
- (NSArray *)getActualDevicesArray
{
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *dict = [self getDevicesDictForTypeWithKey:@"isActual" value:@(YES)];
    for (NSString *key in dict.allKeys) {
        for (DeviceForUser *model in dict[key]) {
            [array addObject:model];
        }
    }
    return array;
}

#pragma mark - 获取当前区域的流程
- (NSArray *)processByCurrentArea
{
    return self.allProcessDict[kCurrentArea.AreaID];
}

#pragma mark - 根据设备ID获取当前区域的实体设备
- (DeviceForUser *)getActualDeviceWithID:(NSInteger)deviceID
{
    for (DeviceForUser *model in [self getActualDevicesArray]) {
        if (model.AutoID == deviceID) {
            return model;
        }
    }
    return nil;
}

#pragma mark - 根据设备ID获取设备(包含公共设备)
- (DeviceForUser *)getDeviceWithUEQP_ID:(NSString *)UEQP_ID
{
    NSArray *devicesArray = self.allDevicesDict[self.currentArea.AreaID];
    for (DeviceForUser *model in devicesArray) {
        if ([model.UEQP_ID isEqualToString:UEQP_ID]) {
            return model;
        }
    }
    for (DeviceForUser *model in self.commonDeviceArray) {
        if ([model.UEQP_ID isEqualToString:UEQP_ID]) {
            return model;
        }
    }
    return nil;
}

#pragma mark 获取当前区域所有设备中,设备类型信息符合key和value的设备
- (NSDictionary *)getDevicesDictForTypeWithKey:(NSString *)key value:(id)value
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *devicesArray = self.allDevicesDict[self.currentArea.AreaID];
    for (DeviceForUser *model in devicesArray) {
        NSString *type = model.UEQP_Type;
        // 判断当前设备是输出或者输入
        if ([self.deviceTypeDict[type][key] isEqual:value]) {
            if (dict[type]) {
                [dict[type] addObject:model];
            } else {
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:model];
                [dict setObject:array forKey:type];
            }
        }
    }
    return dict;
}

#pragma mark - 获取当前区域指定类型的所有设备
- (NSArray *)getDeviceWithType:(NSString *)deviceType
{
    NSMutableArray *result = nil;
    NSArray *devicesArray = self.allDevicesDict[self.currentArea.AreaID];
    for (DeviceForUser *model in devicesArray) {
        if ([model.UEQP_Type isEqualToString:deviceType]) {
            if (!result) {
                result = [NSMutableArray arrayWithObject:model];
            } else {
                [result addObject:model];
            }
        }
    }
    return result;
}

#pragma mark - 根据设备类型获取该类型信息
- (NSDictionary *)getInfoWithDeviceType:(NSString *)deviceType
{
    return self.deviceTypeDict[deviceType];
}

#pragma mark - 根据当前设备,获取该设备可连接的所有其他设备(设备为in类型,则返回空.默认只有out类型的设备,才显示可连接设备[因为in类型的设备,可连接多个out.界面不好显示连接的状态])
- (NSMutableArray *)getAllowConnectedDevicesWithModel:(DeviceForUser *)model
{
    NSDictionary *type = [self getInfoWithDeviceType:model.UEQP_Type];
    // 默认只有out类型的设备,才显示可连接设备[因为in类型的设备,可连接多个out.界面不好显示连接的状态]
    if ([type[@"inOrOut"] isEqualToString:@"in"]) {
        return nil;
    }
    NSArray *allowConnectedDevices = [type[@"soundConnectedType"] arrayByAddingObjectsFromArray:type[@"videoConnectedType"]];
    NSMutableArray *result = [NSMutableArray array];
    // 便利字典
    [[self getInDevicesDict] enumerateKeysAndObjectsUsingBlock:^(NSString *type, NSArray *devices, BOOL *stop) {
        if ([allowConnectedDevices containsObject:type]) {
            [result addObjectsFromArray:devices];
        }
    }];
    return result;
    
}
#pragma mark - 获取所有区域
- (NSArray *)getAllAreas
{
    return self.allAreasArray;
}

#pragma mark - 改变选择区域
- (void)changeAreaWithIndex:(NSInteger)index
{
    self.currentArea = self.allAreasArray[index];
    _actualImage = nil;
}
#pragma mark - 获取所有设备字典
- (NSDictionary *)getAllDevices
{
    return self.allDevicesDict;
}

#pragma mark - 公共设备列表
- (NSArray *)commonDevices
{
    return  self.commonDeviceArray;
}

- (NSArray *)musicFiles
{
    return [self getDeviceWithType:kDeviceTypeMusicFile];
}

#pragma mark - 实景图
- (UIImage *)actualImageWithViewpointType:(ViewPointType)viewpointType
{
    NSString *filePath = kActualImageFilePathWithAreaName([[Common shareCommon] areaName], @(viewpointType));
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    return  [UIImage imageWithContentsOfFile:filePath];
}


- (void)setActualImage:(UIImage *)actualImage withViewpointType:(ViewPointType)viewpointType
{
    NSString *filePath = kActualImageFilePathWithAreaName([[Common shareCommon] areaName], @(viewpointType));
    // 创建目录
    if (![[NSFileManager defaultManager] fileExistsAtPath:kActualImageFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kActualImageFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 保存图片
    if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImagePNGRepresentation(actualImage) attributes:nil]) {
        kLog(@"Save Success");
    }
}

#pragma mark - 登陆
- (void)loginWithUserName:(NSString *)userName
                      pwd:(NSString *)pwd
               remeberPwd:(BOOL)remeberPwd
                autoLogin:(BOOL)autoLogin
         completionHandle:(void (^)(BOOL isSuccess, NSString *errorDescription))completionHandle
{
    __weak typeof(self) weakSelf = self;
    [self checkPermissionWithUserName:userName pwd:pwd completionHandle:^(BOOL isSucess) {
        if (isSucess) {
            weakSelf.currentUser.remeberPwd = remeberPwd;
            weakSelf.currentUser.autoLogin = autoLogin;
            if (![Common shareCommon].isDemo) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:weakSelf.currentUser] forKey:kLocalUserKey];
            }
            
            [weakSelf initalDataWithCompletionHandle:^(BOOL hasData, NSString *errorInfo) {
                if (hasData) {
                    weakSelf.currentArea = weakSelf.allAreasArray.firstObject;
                    completionHandle(YES, nil);
                } else {
                    if (completionHandle) {
                        completionHandle(NO, errorInfo);
                    }
                }
            }];
        } else {
            if (completionHandle) {
                completionHandle(NO, @"用户名或密码错误,请重试!");
            }
        }
        
    }];
}

- (void)loadProcessDataListWithCompletionHandle:(void (^)(BOOL, NSString *))completionHandle
{
    [[SocketManager shareSocketManager] getXJListWithResultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
        if (isSuccess) {
            if ([info length] > 0) {
                NSArray *processArray = [info componentsSeparatedByString:@"&"];
                int i = 0;
                // 服务器有返回,则不为nil.
                self.allProcessDict = [NSMutableDictionary dictionary];
                for (NSString *processString in processArray) {
                    if ([processString length] > 0) {
                        Process *process = [Process new];
                        process.AreaID = [processString componentsSeparatedByString:@","][0];
                        process.processId = [processString componentsSeparatedByString:@","][1];
                        process.processName = [processString componentsSeparatedByString:@","][2];
                        process.processInfo = [processString componentsSeparatedByString:@","][3];
                        if (self.allProcessDict[process.AreaID]) {
                            [self.allProcessDict[process.AreaID] addObject:process];
                        } else {
                            NSMutableArray *array = [NSMutableArray arrayWithObject:process];
                            [self.allProcessDict setObject:array forKey:process.AreaID];
                        }
                    } else {
                        kLog(@"第%d条流程无效", i + 1);
                    }
                    i++;
                }
                if (completionHandle) {
                    completionHandle(YES, nil);
                }
            } else {
                if (completionHandle) {
                    completionHandle(NO, @"服务器尚未配置流程!");
                }
            }
        } else {
            if (completionHandle) {
                completionHandle(NO, @"服务器连接失败");
            }
        }
    }];
}

- (void)checkPermissionWithUserName:(NSString *)userName
                                pwd:(NSString *)pwd
                   completionHandle:(void(^)(BOOL isSucess))completionHandle
{
    
    
    
    __weak typeof(self) weakSelf = self;
    [[SocketManager shareSocketManager] loginWithUserId:userName pwd:pwd resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
        NSInteger level = [[info componentsSeparatedByString:@"&"].lastObject integerValue];
        if (level > 0) {
            User *user  = [User new];
            user.name = userName;
            user.pwd = pwd;
            user.timestampByLogin = (long)[NSDate date];
            user.level = level;
            
            weakSelf.currentUser = user;
            [Common shareCommon].hasLogin = YES;
            if (completionHandle) {
                completionHandle(YES);
            }
        } else { // 验证失败
//            weakSelf.currentUser = nil;
            if (completionHandle) {
                completionHandle(NO);
            }
        }
    }];
}

#pragma mark - 注销登陆
- (void)logout
{
    [Common shareCommon].hasLogin = NO;
    [[Common shareCommon] clearCacheData];
    [[SocketManager shareSocketManager] breakTcpSocket];
}
#pragma mark - 保存日志
- (void)cacheLogWithModel:(LogInfo *)logInfo
{
    [_logDict setObject:logInfo forKey:@(logInfo.cmdNumber)];
}


#pragma mark - 获取此次启动后的日志
- (NSDictionary *)logDict
{
    return _logDict;
}

#pragma mark - 从服务器获取基础数据（区域、设备）
- (void)loadBaseDataFromServerWithCompletionHandle:(void (^)(BOOL hasData, NSString *errorInfo))completionHandle
{
    
}

#pragma mark - 第一次加载基础数据(所有设备等等)
- (void)initalDataWithCompletionHandle:(void (^)(BOOL hasData, NSString *errorInfo))completionHandle
{
    // 从WebServer获取系统所有设备
    NSData *deviceTypeData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeviceType" ofType:@"json"]];
    // 设备类型的信息, 从本地json获取
    self.deviceTypeDict = [NSJSONSerialization JSONObjectWithData:deviceTypeData options:NSJSONReadingAllowFragments error:nil];
    
    if (self.isDemo) {
        self.allAreasArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            NSDictionary *dict = @{@"AreaID" : [NSString stringWithFormat:@"AreaID%02d", i],
                                   @"AreaName" : [NSString stringWithFormat:@"区域%02d", i]
                                   };
            Area *area = [Area new];
            [area setValuesForKeysWithDictionary:dict];
            [self.allAreasArray addObject:area];
        }
        
        self.allDevicesDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < 40; i++) {
            
            NSString *typeString = self.deviceTypeDict.allKeys[i % self.deviceTypeDict.allKeys.count];
            // 允许开关的设备,默认打开
            NSInteger deviceOCState = 0;
            if ([self.deviceTypeDict[typeString][@"controlCMD"] containsObject:@"oc"]) {
                deviceOCState = 1;
            }
            NSDictionary *dict = @{@"AutoID" : @(i + 100),
                                   @"UEQP_ID" : [NSString stringWithFormat:@"UEQP_ID%02d", i],
                                   @"UEQP_Name" : [NSString stringWithFormat:@"%@%02d", typeString, i],
                                   @"UEQP_Type" : typeString,
                                   @"AreaID" : [NSString stringWithFormat:@"AreaID%02ld", (long)i % self.allAreasArray.count],
                                   @"deviceConnectState" : @(1),
                                   @"needFollow" : @(1),
                                   @"deviceOCState" : @(deviceOCState)
                                   };
            
            DeviceForUser *model = [DeviceForUser new];
            [model setValuesForKeysWithDictionary:dict];
            if (self.allDevicesDict[model.AreaID]) {
                [self.allDevicesDict[model.AreaID] addObject:model];
            } else {
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:model];
                [self.allDevicesDict setObject:array forKey:model.AreaID];
            }
        }
        
        self.commonDeviceArray = [NSMutableArray array];
        for (int i = 0; i < self.deviceTypeDict.count; i++) {
            NSString *typeString = self.deviceTypeDict.allKeys[i % self.deviceTypeDict.allKeys.count];
            // 允许开关的设备,默认打开
            NSInteger deviceOCState = 0;
            if ([self.deviceTypeDict[typeString][@"controlCMD"] containsObject:@"oc"]) {
                deviceOCState = 1;
            }
            NSDictionary *dict = @{@"AutoID" : @(i + 1000),
                                   @"UEQP_ID" : [NSString stringWithFormat:@"UEQP_ID%02d", 100 + i],
                                   @"UEQP_Name" : [NSString stringWithFormat:@"%@%02d", typeString, 100 + i],
                                   @"UEQP_Type" : typeString,
                                   @"AreaID" : [NSString stringWithFormat:@"AreaID%02d", 100],
                                   @"deviceConnectState" : @(1),
                                   @"needFollow" : @(1),
                                   @"deviceOCState" : @(deviceOCState)
                                   };
            
            DeviceForUser *model = [DeviceForUser new];
            [model setValuesForKeysWithDictionary:dict];
            [self.commonDeviceArray addObject:model];
        }
        
       
        if (completionHandle) {
            completionHandle(YES, nil);
        }
        

    } else { // 从PC获取
        [WFFProgressHud showWithStatus:@"加载数据..."];
        
        __weak typeof(self) weakSelf = self;
        /**
         *  错误信息
         */
        static NSString *errorDes;
        /**
         *  公共设备的区域ID -- 服务器的公共设备,为独立区域.用字符串"公共设备"命名
         */
        static NSString *commonAreaID;
        errorDes = nil;
        commonAreaID = nil;
        // 5秒后获取不到数据,就认定网络连接故障
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 判断当前是否登陆状态.
            // 如果不加登陆状态的判断.当用户登陆后马上注销.此时数据均为空.就会提示错误.
            if (weakSelf.hasLogin && (!weakSelf.allAreasArray || !weakSelf.allDevicesDict)) {
                if (completionHandle) {
                    completionHandle(NO, errorDes ? errorDes : @"服务器连接超时!请重试!");
                }
                [WFFProgressHud dismiss];
            }
        
        });
//        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            [[SocketManager shareSocketManager] getDataListWithType:DataListTypeArea resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
                NSArray *areaArray = [info componentsSeparatedByString:@"&"];
                if (isSuccess) {
                    weakSelf.allAreasArray = [NSMutableArray array];
                    for (NSString *areaString in areaArray) {
                        Area *area = [Area new];
                        area.AreaID = [areaString componentsSeparatedByString:@","][0];
                        area.AreaName = [areaString componentsSeparatedByString:@","][1];
                        // 判断是否公共设备
                        if ([area.AreaName isEqualToString:@"公共设备"]) {
                            commonAreaID = area.AreaID;
                        } else {
                            [weakSelf.allAreasArray addObject:area];
                        }
                    }
                    kLog(@"%@", weakSelf.allAreasArray);
                    if ([weakSelf.allAreasArray count] == 0) {
                        errorDes = @"服务器没有配置区域列表!";
                    } else {
                        if ([weakSelf.allDevicesDict count] > 0) {
                            if (completionHandle) {
                                completionHandle(errorDes == nil, errorDes);
                            }
                        }
                    }
                } else {
                    errorDes = @"获取区域列表失败!请重试!";
                }
            }];
        });
        dispatch_async(queue, ^{
            [[SocketManager shareSocketManager] getDataListWithType:DataListTypeDevice resultBlock:^(BOOL isSuccess, NSInteger cmdNumber, NSString *info) {
                NSArray *areaArray = [info componentsSeparatedByString:@"&"];
                if (isSuccess) {
                    static NSInteger countOfDevice = 0;
                    weakSelf.allDevicesDict = [NSMutableDictionary dictionary];
                    for (NSString *deviceString in areaArray) {
                        NSArray *device = [deviceString componentsSeparatedByString:@","];
                        DeviceForUser *model = [DeviceForUser new];
                        model.AutoID = 100 + (countOfDevice++);// 防止0的出现.后面要吧这个id作为设备view的tag值
                        model.UEQP_ID = device[0];
                        model.UEQP_Name = device[1];
                        model.UEQP_Type = device[2];
                        model.AreaID = device[3];
                        // 设备操控所需权限
                        model.needLevel = [device[4] integerValue];
                        // 跟随功能的配置
                        if ([device[5] isEqualToString:@"0"] || [device[5] isEqualToString:@"1"]) { // 该设备为摄像头.是否开启跟随
                            model.needFollow = [device[5] boolValue];
                        } else if ([device[5] length] == 0){ // 设置了跟随的镜头
                            model.followUEQP_ID = nil;
                        } else {
                            model.followUEQP_ID = device[5];
                        }
                        
                        // 判断是否为公共设备
                        if ([model.AreaID isEqualToString:commonAreaID]) {
                            if (!weakSelf.commonDeviceArray) {
                                weakSelf.commonDeviceArray = [NSMutableArray arrayWithObject:model];
                            } else {
                                [weakSelf.commonDeviceArray addObject:model];
                            }
                        } else {
                            if (weakSelf.allDevicesDict[model.AreaID]) {
                                [weakSelf.allDevicesDict[model.AreaID] addObject:model];
                            } else {
                                NSMutableArray *array = [NSMutableArray array];
                                [array addObject:model];
                                [weakSelf.allDevicesDict setObject:array forKey:model.AreaID];
                            }
                        }
                    }
                    kLog(@"%@", weakSelf.allDevicesDict);

                    if ([weakSelf.allDevicesDict count] == 0) {
                        errorDes = @"服务器没有配置设备列表!";
                    } else {
                        if ([weakSelf.allAreasArray count] > 0) {
                            if (completionHandle) {
                                completionHandle(errorDes == nil, errorDes);
                            }
                        }
                    }
                } else {
                    errorDes = @"获取设备列表失败!请重试!";
                }
            }];

        });
//        // 数据都加载结束，执行
//        dispatch_group_notify(group, queue, ^{
//            if (completionHandle) {
//                completionHandle(errorDes == nil, errorDes);
//            }
//            [WFFProgressHud dismiss];
//        });
        
    }
}

#pragma mark - 清除当前区域所有设备的配置信息
- (void)clearConfigOfAllDevice
{
    NSArray *array = self.allDevicesDict[self.currentArea.AreaID];
    for (DeviceForUser *model in array) {
        model.currentConfigs = nil;
    }
}

- (void)clearCacheData
{
    self.allDevicesDict = nil;
    self.allAreasArray = nil;
    self.commonDeviceArray = nil;
}
@end
