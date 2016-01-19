//
//  SocketManager.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/14.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "SocketManager.h"
#import "Area.h"
#define kHeartHitTimeOut 10
@interface SocketManager ()<GCDAsyncSocketDelegate> {
    
    dispatch_source_t timer;
    dispatch_source_t serverTimer; // 服务器心跳包计时
}

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

@property (nonatomic, strong) GCDAsyncSocket *pcSocket;

@property (nonatomic, strong) NSMutableDictionary *operationBlockDict;// 操作后,回调的block的字典.  键:编号  值:block

@property (nonatomic, strong) NSMutableString *readStream; // 读取到的数据流


@end

static int serverTimerLastHeartHit; // 服务器心跳包倒计时 -- 5秒没接收到认为失去连接,则断开当前套接字,重新创建监听端口



@implementation SocketManager

kSingleTon_M(SocketManager)

- (instancetype)init
{
    if (self = [super init]) {
    }
    
    return self;
}

#pragma mark - 创建套接字
- (void) createTcpSocket {
    
    
    if ([Common shareCommon].isDemo) {
        return;
    }
    
    if (self.state == SocketStateDisConnected && _serverSocket == nil) {
        // 创建一个后台的队列 等待接收数据
        dispatch_queue_t dQueue = dispatch_queue_create("My socket queue", NULL);
        // 1. 创建一个tcp socket套接字对象
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
        // 2. 绑定监听端口
        [_serverSocket acceptOnPort:8000 error:nil];
        
//        // 要连接,说明之前已经断开.重新开始计算命令编号
//        currentNum = 1;
        
        kLog(@"开始监听8000端口,等待连接...%d", _serverSocket.isConnected);
    }
    
    
}

- (void) breakTcpSocket {
    if (self.state == SocketStateConnected) {
        //        self.state = SocketStateDisConnected;
        [self stopNetLink];
    }
    [self.pcSocket disconnect];
    [self.serverSocket disconnect];
    self.pcSocket = nil;
    self.serverSocket = nil;
}

#pragma mark - 心跳包
- (void)startNetLink
{
    timer = NULL;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 5.0f * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sendHeartBeat];
        });
    });
    dispatch_resume(timer);
    
    // 服务器心跳包计时. 当接收到心跳包,重置变量值为5;
    serverTimerLastHeartHit = kHeartHitTimeOut;
    serverTimer = NULL;
    serverTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(serverTimer, dispatch_walltime(NULL, 0), 1.0f * NSEC_PER_MSEC, 0);
    dispatch_source_set_event_handler(serverTimer, ^{
        serverTimerLastHeartHit--;
        if (serverTimerLastHeartHit < 0) { // 心跳包丢失
            // 中断
            [weakSelf breakTcpSocket];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidConnectedStateChange object:nil];
            // /重新监听
            [weakSelf createTcpSocket];
        }
    });
}

- (void)stopNetLink
{
    if (timer != NULL) {
        dispatch_source_cancel(timer);
    }
}
#pragma mark - setter
- (void)setPcSocket:(GCDAsyncSocket *)pcSocket
{
    if (_pcSocket != pcSocket) {
        if (pcSocket) {
            _pcSocket = nil;
            _pcSocket = pcSocket;
            _pcSocket.delegate = self;
            self.state = SocketStateConnected;
        } else {
            _pcSocket = nil;
            self.state = SocketStateDisConnected;
        }
    }
}

#pragma mark - 根据当前读取的缓冲流,获取含包头包尾的协议串,并对当前缓冲流进行处理
- (void)doSomethingFromStream
{
    if (![self.readStream containsString:kEnd]) {
        return ;
    }
    // 获取第一个结尾
    NSRange endRangeForSearch = [self.readStream rangeOfString:kEnd];
    NSRange endRange = NSMakeRange(0, endRangeForSearch.location + endRangeForSearch.length);
    // 获取到第一个结尾为止的字符串
    NSString *endString = [self.readStream substringWithRange:endRange];
    // 截掉子串
    [self.readStream deleteCharactersInRange:endRange];
    
    // 获取子串的最后一个开头
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:kHead options:0 error:nil];
    NSArray *array = [reg matchesInString:endString options:0 range:NSMakeRange(0, endString.length)];
    if (array.count > 0) {
        NSTextCheckingResult *lastResult = array.lastObject;
        NSString *protocol = [endString substringFromIndex:lastResult.range.location];
        kLog(@"提取到的串 %@", protocol);
        // 根据获取到的形似协议的串进行处理
        [self doSomethingWithProtocolString:protocol];
        // 接着操作剩余的串
        [self doSomethingFromStream];
    } else {
        return ;
    }
}

#pragma mark - 根据协议串执行相应操作
- (void)doSomethingWithProtocolString:(NSString *)protocolString
{
    //    if (![Common shareCommon].hasLogin) {
    //        return;
    //    }
    //    if (![self checkProtocolString:protocolString]) {
    //        kLog(@"%@ 不合法的协议", protocolString);
    //        return ;
    //    }
    
    
    // 心跳包
    //    if ([protocolString containsString:kProtocolNetLink]) {
    serverTimerLastHeartHit = kHeartHitTimeOut;
    //    }
    
    
    // 操作流程
    if ([protocolString containsString:kProtocolCMDFromServerForDoProcess]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        if (block) {
            block(YES, cmdNum, nil);
        }
        // 执行完移除
        [self.operationBlockDict removeObjectForKey:@(cmdNum)];
    }
    
    // 流程列表
    if ([protocolString containsString:kProtocolCMDFromServerForXJList]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        if (block) {
            NSString *info = (NSString *)[self getItemWithProtocolString:protocolString index:4];
            block(YES, cmdNum, info);
        }
        // 执行完移除
        [self.operationBlockDict removeObjectForKey:@(cmdNum)];

    }
    
    if ([protocolString containsString:kProtocolCMDFromServerForCameraFollow]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        NSString *info = (NSString *)[self getItemWithProtocolString:protocolString index:4];
        if (block) {
            if ([info isEqualToString:@"OK"]) { // OK
                block(YES, cmdNum, info);
            } else { // ERROR
                block(NO, cmdNum, info);
            }
        }
        // 执行完移除
        [self.operationBlockDict removeObjectForKey:@(cmdNum)];
    }
    
    // 登陆验证
    if ([protocolString containsString:kProtocolCMDFromServerForLogin]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        if (block) {
            NSString *info = (NSString *)[self getItemWithProtocolString:protocolString index:4];
            block(YES, cmdNum, info);
        }
        // 执行完移除
        [self.operationBlockDict removeObjectForKey:@(cmdNum)];
        
    }
    // 设备控制反馈. 获取控制编号,取出其中的block执行
    if ([protocolString containsString:kProtocolCMDFromServerForRespondControlDevice]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        if (block) {
            NSString *info = (NSString *)[self getItemWithProtocolString:protocolString index:4];
            block(YES, cmdNum, info);
        }
        // 执行完移除
        [self.operationBlockDict removeObjectForKey:@(cmdNum)];
    }
    // 更新设备状态
    if ([protocolString containsString:kProtocolCMDFromServerToUpdate]) {
        DeviceForUser *device = [self getDeviceWithProtocolString:protocolString];
        if (device) {
            //            kLog(@"设备更新发出通知 : %@", device);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateDevice object:device];
        }
    }
    // 获取区域列表
    if ([protocolString containsString:kProtocolCMDFromServerForAreaList]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        if (block) {
            NSString *cmd = (NSString *)[self getItemWithProtocolString:protocolString index:4];
            block(YES, cmdNum, cmd);
        }
    }
    // 获取设备列表
    if ([protocolString containsString:kProtocolCMDFromServerForDeviceList]) {
        NSInteger cmdNum = [[self getItemWithProtocolString:protocolString index:2] integerValue];
        RequestServerResponseBlock block = self.operationBlockDict[@(cmdNum)];
        if (block) {
            NSString *cmd = (NSString *)[self getItemWithProtocolString:protocolString index:4];
            block(YES, cmdNum, cmd);
        }
    }
}

#pragma mark - Socket Delegate
#pragma mark 接收到一个请求
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {

    // 建立连接
    kLog(@"%@", @"建立连接");
    self.pcSocket = newSocket;
    self.readStream = [NSMutableString string];
    self.operationBlockDict = [NSMutableDictionary dictionary];
    // 开始
    [self startNetLink];
    // 不断读数据
    [newSocket readDataWithTimeout:-1 tag:200];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidConnectedStateChange object:nil];
    });
    
}

#pragma mark 接收到数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (sock != self.pcSocket) {
        return;
    }
    // GBK编码
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    // 解码
    NSString *string = [[NSString alloc] initWithData:data encoding:enc];
    
    // 获取到的数据拼接到缓存中.
    [self.readStream appendString:string];
    
    kLog(@"接收到新数据 - 线程 %@  当前数据 : %@", [NSThread currentThread], self.readStream);
    // 每次获取到就调用 -- 提取出协议串并处理
    [self doSomethingFromStream];
    
    // 只读一次,因此再次执行,继续读数据
    [sock readDataWithTimeout:-1 tag:200];
}

// 失去连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {

    // 停止心跳包 - 必须停止,否则再次连接重复开启,发送心跳包频率加快
    [self stopNetLink];
    
    kLog(@"失去连接 %@", err);
    // setter方法,设置连接状态
    self.pcSocket = nil;
    self.operationBlockDict = nil;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidConnectedStateChange object:nil];
    });
    
}

// 发送数据成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (sock != self.pcSocket) {
        return;
    }
    if (tag == 0) {
        kLog(@"心跳包发送成功~~");
        return;
    }
    kLog(@"命令编号:%ld 发送成功", tag);
}

// 发送数据超时
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if (sock != self.pcSocket) {
        return 0;
    }
    if (tag == 0) {
        kLog(@"心跳包发送失败~~");
        return 0;
    }
    kLog(@"命令编号:%ld 发送失败", tag);
    // 执行block
    RequestServerResponseBlock block = self.operationBlockDict[@(tag)];
    if (block) {
        block(NO, tag, nil);
    }
    // 发送失败 移除block
    [self.operationBlockDict removeObjectForKey:@(tag)];
    return 0;
}

#pragma mark - 公有方法

#pragma mark - 发送数据

/**
 *   发送消息
 *
 *  @param cmdString   命令字
 *  @param cmdInfo     信息元
 *  @param resultBlock 回调block
 */
- (void)sendMessageWithCMD:(NSString *)cmdString
                   cmdInfo:(NSString *)cmdInfo // 控制设备此字段为空,由sub来拼凑
               resultBlock:(RequestServerResponseBlock)resultBlock
{
    // 生成协议串,并转成要发送的data数据
    NSString *protocolString = [self getProtocolStringWithCMD:cmdString info:cmdInfo];
    
    NSData *data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
        if (resultBlock) {
            resultBlock(NO, currentNum, nil);
        }
    } else {
        // 发送成功后执行代理方法 didWriteData
        [self.pcSocket writeData:data withTimeout:kTimeOut tag:currentNum];
        // 有连接则发送,发送后保存block. 当发送失败移除block,当接收到回应,执行block,并移除
        [self.operationBlockDict setObject:[resultBlock copy] forKey:@(currentNum)];
    }
    currentNum++;
}

// 心跳包
- (void)sendHeartBeat
{
    NSString *protocolString = [self getProtocolStringWithCMD:kProtocolNetLink info:nil];
    
    NSData *data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
        return;
    } else {
        // 发送成功后执行代理方法 didWriteData
        [self.pcSocket writeData:data withTimeout:kTimeOut tag:0];
    }
}


// 获取基础数据
- (void)getDataListWithType:(DataListType)type
                resultBlock:(RequestServerResponseBlock)resultBlock
{
    NSString *protocolCMD = nil;
    switch (type) {
        case DataListTypeArea:
            protocolCMD = kProtocolGetAreaList;
            break;
        case DataListTypeDevice:
            protocolCMD = kProtocolGetDeviceList;
            break;
    }
    [self sendMessageWithCMD:protocolCMD cmdInfo:nil resultBlock:resultBlock];
//    // 生成协议串,并转成要发送的data数据
//    NSString *protocolString = [self getProtocolStringWithCMD:protocolCMD info:nil];
//    
//    NSData *data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
//        if (resultBlock) {
//            resultBlock(NO, currentNum, nil);
//        }
//    } else {
//        // 发送成功后执行代理方法 didWriteData
//        [self.pcSocket writeData:data withTimeout:kTimeOut tag:currentNum];
//        // 有连接则发送,发送后保存block. 当发送失败移除block,当接收到回应,执行block,并移除
//        [self.operationBlockDict setObject:[resultBlock copy] forKey:@(currentNum)];
//    }
//    currentNum++;
}


/**
 *  登陆验证
 *
 *  @param userId      用户ID
 *  @param pwd         密码
 *  @param resultBlock 回调block
 */
- (void)loginWithUserId:(NSString *)userId
                    pwd:(NSString *)pwd
            resultBlock:(RequestServerResponseBlock)resultBlock
{
    
    if ([Common shareCommon].isDemo) {
        if (resultBlock) {
            // 模拟返回999权限的用户
            resultBlock(YES, currentNum, @"&999");
        }
        currentNum++;
        return;
    }
    
    NSString *info = [NSString stringWithFormat:@"%@&%@", userId, pwd];
    [self sendMessageWithCMD:kProtocolLogin cmdInfo:info resultBlock:resultBlock];
//    // 生成协议串,并转成要发送的data数据
//    NSString *protocolString = [self getProtocolStringWithCMD:kProtocolLogin info:info];
//    
//    NSData *data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
//        if (resultBlock) {
//            resultBlock(NO, currentNum, nil/*[NSString stringWithFormat:@"%@&%@", userId, @"-1"]*/);
//        }
//    } else {
//        // 发送成功后执行代理方法 didWriteData
//        [self.pcSocket writeData:data withTimeout:kTimeOut tag:currentNum];
//        // 有连接则发送,发送后保存block. 当发送失败移除block,当接收到回应,执行block,并移除
//        [self.operationBlockDict setObject:[resultBlock copy] forKey:@(currentNum)];
//    }
//    currentNum++;
//    
}


/**
 *  获取流程列表
 *
 *  @param resultBlock 回调block
 */
- (void)getXJListWithResultBlock:(RequestServerResponseBlock)resultBlock
{
    if ([Common shareCommon].isDemo) {
        if (resultBlock) {
            // 模拟返回999权限的用户
            resultBlock(YES, currentNum, [NSString stringWithFormat:@"%@,process001,流程001,说明说明...&%@,process002,流程002,说明说明说明.", kCurrentArea.AreaID, kCurrentArea.AreaID]);
        }
        currentNum++;
        return;
    }
    
    [self sendMessageWithCMD:kProtocolGetXJList cmdInfo:nil resultBlock:resultBlock];
//    // 生成协议串,并转成要发送的data数据
//    NSString *protocolString = [self getProtocolStringWithCMD:kProtocolGetXJList info:nil];
//    
//    NSData *data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
//        if (resultBlock) {
//            resultBlock(NO, currentNum, nil);
//        }
//    } else {
//        // 发送成功后执行代理方法 didWriteData
//        [self.pcSocket writeData:data withTimeout:kTimeOut tag:currentNum];
//        // 有连接则发送,发送后保存block. 当发送失败移除block,当接收到回应,执行block,并移除
//        [self.operationBlockDict setObject:[resultBlock copy] forKey:@(currentNum)];
//    }
//    currentNum++;
}



/**
 *  处理流程
 *
 *  @param processID   流程ID
 *  @param isStart     开始或者停止
 *  @param resultBlock 回调block
 */
- (void)doByProcessWithProcessID:(NSString *)processID
                         isStart:(BOOL)isStart
                     resultBlock:(RequestServerResponseBlock)resultBlock
{
    NSString *info = [NSString stringWithFormat:@"%@&%@", isStart ? @"OPEN" : @"CLOSE", processID];
    [self sendMessageWithCMD:kProtocolCMDByDoProcess cmdInfo:info resultBlock:resultBlock];
//    // 生成协议串,并转成要发送的data数据
//    NSString *protocolString = [self getProtocolStringWithCMD:kProtocolCMDByDoProcess info:info];
//    
//    NSData *data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
//        if (resultBlock) {
//            resultBlock(NO, currentNum, nil);
//        }
//    } else {
//        // 发送成功后执行代理方法 didWriteData
//        [self.pcSocket writeData:data withTimeout:kTimeOut tag:currentNum];
//        // 有连接则发送,发送后保存block. 当发送失败移除block,当接收到回应,执行block,并移除
//        [self.operationBlockDict setObject:[resultBlock copy] forKey:@(currentNum)];
//    }
//    currentNum++;
}

// 信息元 --  设备编号1,设备编号2,…&命令&命令参数[&控制地址]
- (void)ctrlDevicesWithDevicesID:(NSString *)devicesID
                     ControlType:(CMDType)controlType
                             arg:(NSString *)arg
                     resultBlock:(RequestServerResponseBlock)resultBlock
{
    
    if ([Common shareCommon].isDemo) {
        NSString *info = @"";
        // 演示版,(开关操作,模拟成功)模拟成功
        if (controlType == CMDTypeOpen || controlType == CMDTypeClose) {
            for (NSString *item in [devicesID componentsSeparatedByString:@","]) {
                info = [info stringByAppendingFormat:@"%@,1&", item];
            }
            // 删除最后一个&
            [info substringWithRange:NSMakeRange(0, info.length - 1)];
        }
        if (resultBlock) {
            resultBlock(YES, currentNum, info);
        }
        currentNum++;
        return;
    }
    
    NSMutableString *info = [NSMutableString string];
    // 不直接初始化,是防止devicesID为nil的情况出现.导致崩溃
    [info appendString:devicesID];
    NSString *control = nil;
    BOOL isEQPCTRL = YES;
    switch (controlType) {
        case CMDTypeClose:
            control = kProtocolControlDeviceCMDOfClose; // EQPCTRlOK
            break;
        case CMDTypeOpen:
            control = kProtocolControlDeviceCMDOfOpen; // EQPCTRlOK
            break;
        case CMDTypeSetValue:
            control = kProtocolControlDeviceCMDOfSetValue; // EQPCTRlOK
            break;
        case CMDTypeGet:
            control = kProtocolControlDeviceCMDOfGet; // UPDATE
            break;
        case CMDTypeConn:
            control = kProtocolControlDeviceCMDofConn; // EQPCTRlOK
            break;
        case CMDTypeCaDown:
            control = kProtocolControlDeviceCMDofDown; // EQPCTRlOK
            break;
        case CMDTypeCaLeft:
            control = kProtocolControlDeviceCMDofLeft; // EQPCTRlOK
            break;
        case CMDTypeCaRight:
            control = kProtocolControlDeviceCMDofRight; // EQPCTRlOK
            break;
        case CMDTypeCaStop:
            control = kProtocolControlDeviceCMDofStop; // EQPCTRlOK
            break;
        case CMDTypeCaUp:
            control = kProtocolControlDeviceCMDofUp; // EQPCTRlOK
            break;
        case CMDTypeChangeChannel:
            control = kProtocolControlDeviceCMDofChangeChannel; // EQPCTRlOK
            break;
        case CMDTypeConfigCameraFollow:
            isEQPCTRL = NO;
            break;
    }
//    NSData *data = nil;
    if (isEQPCTRL) { // 控制设备
        //
        [info appendFormat:@"&%@", control];
        [info appendFormat:@"&%@", arg ? arg : @""];
        [self sendMessageWithCMD:kProtocolCMDByControlDevice cmdInfo:info resultBlock:resultBlock];
//        // 生成协议串,并转成要发送的data数据
//        NSString *protocolString = [self getProtocolStringWithCMD:kProtocolCMDByControlDevice info:info];
//        kLog(@"%@", protocolString);
//        data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        [info appendFormat:@"&%@", arg ? arg : @""];
        [self sendMessageWithCMD:kProtocolCMDByCameraFollow cmdInfo:info resultBlock:resultBlock];
//        // 生成协议串,并转成要发送的data数据
//        NSString *protocolString = [self getProtocolStringWithCMD:kProtocolCMDByCameraFollow info:info];
//        kLog(@"%@", protocolString);
//        data = [protocolString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
//    if (!self.state) {//判断当前是否连接 SocketStateConnected = 1
//        if (resultBlock) {
//            resultBlock(NO, currentNum, nil);
//        }
//    } else {
//        // 发送成功后执行代理方法 didWriteData
//        [self.pcSocket writeData:data withTimeout:kTimeOut tag:currentNum];
//        // 有连接则发送,发送后保存block. 当发送失败移除block,当接收到回应,执行block,并移除
//        [self.operationBlockDict setObject:[resultBlock copy] forKey:@(currentNum)];
//    }
//    currentNum++;
}

#pragma mark - 生成协议串 , 根据命令字+信息元
- (NSString *)getProtocolStringWithCMD:(NSString *)CMD info:(NSString *)info
{
    // 包头
    NSMutableString *result = [NSMutableString stringWithString:kHead];
    // 命令长度
    [result appendString:@"0000@"];
    // 命令方向
    [result appendString:@"C2S@"];
    // 命令编号
    [result appendFormat:@"%04ld@", (long)currentNum];
    // 命令字
    [result appendFormat:@"%@@", CMD];
    // 信息元
    [result appendFormat:@"%@@", info];
    // 校验码
    [result appendString:@"AA"];
    // 包尾
    [result appendString:kEnd];
    
    return result;
}

#pragma mark - 根据更新设备的协议串获取设备信息
- (DeviceForUser *)getDeviceWithProtocolString:(NSString *)protocolString
{
    NSArray *array = [protocolString componentsSeparatedByString:@"@"];
    NSString *info = array[4];
    NSString *UEQP_ID = [info componentsSeparatedByString:@"&"].firstObject;
    DeviceForUser *device = [[Common shareCommon] getDeviceWithUEQP_ID:UEQP_ID];
    NSInteger deviceConnectState = [[[info componentsSeparatedByString:@"&"].lastObject componentsSeparatedByString:@":"].firstObject intValue];
    if (deviceConnectState > 2) { // 开关状态
        device.deviceConnectState = 1;
        device.deviceOCState = (int)deviceConnectState - 2;
    } else  {
        device.deviceConnectState = (int)deviceConnectState;
    }
    
    device.value = [[info componentsSeparatedByString:@"&"].lastObject componentsSeparatedByString:@":"].lastObject;
    
    return device;
}


#pragma mark - 根据协议串获取命令编号

- (id)getItemWithProtocolString:(NSString *)protocolString index:(NSInteger)index
{
    return [protocolString componentsSeparatedByString:@"@"][index];
}

#pragma mark - 检测协议串
- (BOOL)checkProtocolString:(NSString *)protocolString
{
    NSError *error = nil;
    // 包头+4位长度@信息来源标识2信息目的标识@命令编号@命令字+@+信息元（1个或N个）+@2位校验+包尾
    NSString *pattern = [NSString stringWithFormat:@"%@%@%@", kHead, @"[0-9]{4}@[C,S]2[C,S]@[0-9]{4}@.*@.*@[0-9A-Z]{2}", kEnd];
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if ([reg matchesInString:protocolString options:0 range:NSMakeRange(0, protocolString.length)].count > 0) {
        return YES;
    } else {
        return NO;
    }
    
}
@end
