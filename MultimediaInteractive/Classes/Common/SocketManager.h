//
//  SocketManager.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/14.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


/**
 *  发出命令后,接收到服务器返回信息后回调的block
 *
 *  @param isSuccess 是否成功
 *  @param cmdNumber 命令编号
 *  @param info      信息元(参照协议文档)
 */
typedef void (^RequestServerResponseBlock)(BOOL isSuccess, NSInteger cmdNumber, NSString *info);

@interface SocketManager : NSObject
{
    @public
    NSInteger currentNum;
}

kSingleTon_H(SocketManager)

/**
 *  当前连接状态
 */
@property (nonatomic, assign) SocketState state;

/**
 *  发送设备控制指令
 *
 *  @param devicesID   设备ID(可多个)
 *  @param controlType 命令类型
 *  @param arg         参数
 *  @param resultBlock 回调block
 */
- (void)sendMessageWithDevicesID:(NSString *)devicesID
                     ControlType:(CMDType)controlType
                              arg:(NSString *)arg
                       resultBlock:(RequestServerResponseBlock)resultBlock;

/**
 *  获取基础数据(设备列表,区域列表)
 *
 *  @param type        获取的列表类型
 *  @param resultBlock 回调block
 */
- (void)getDataListWithType:(DataListType)type
                resultBlock:(RequestServerResponseBlock)resultBlock;

/**
 *  登陆验证
 *
 *  @param userId      用户ID
 *  @param pwd         密码
 *  @param resultBlock 回调block
 */
- (void)loginWithUserId:(NSString *)userId
                    pwd:(NSString *)pwd
            resultBlock:(RequestServerResponseBlock)resultBlock;

/**
 *  获取流程列表
 *
 *  @param resultBlock 回调block
 */
- (void)getXJListWithResultBlock:(RequestServerResponseBlock)resultBlock;

/**
 *  创建套接字监听
 */
- (void) createTcpSocket;
/**
 *  断开连接
 */
- (void) breakTcpSocket;

@end