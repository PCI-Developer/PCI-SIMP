//
//  LogInfo.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/18.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefixHeader.pch"


/**
 *  重写了description方法
 */
@interface LogInfo : NSObject

/**
 *  设备ID
 */
@property (nonatomic, copy) NSString *UEQP_ID;

/**
 *  其他设备ID(输出源设备才有该字段)
 */
@property (nonatomic, copy) NSString *otherUEQP_ID;

/**
 *  命令类型
 */
@property (nonatomic, assign) CMDType cmdType;

/**
 *  音量(音箱,麦克).频道(电视)
 */
@property (nonatomic, copy) NSString *value;

/**
 *  保留字段.日志或者异常信息(当前都是日志)
 */
@property (nonatomic, assign) LogInfoType type;

/**
 *  命令编号
 */
@property (nonatomic, assign) NSInteger cmdNumber;

/**
 *  时间戳,创建日期.1970年起
 */
@property (nonatomic, assign) NSTimeInterval createDate;

/**
 *  区域ID
 */
@property (nonatomic, copy) NSString *areaID;

/**
 *  创建用户
 */
@property (nonatomic, copy) NSString *createUserID;

/**
 *  操作结果
 */
@property (nonatomic, assign) NSInteger result;



@end
