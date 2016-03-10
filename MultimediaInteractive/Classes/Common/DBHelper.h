//
//  DBHelper.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/14.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  将日志保存到本地数据库
 */
#define kSaveLog(log) [[DBHelper shareDBHelper] insertLog:log]
/**
 *  更新日志结果(当操作接收到服务器返回结果时执行)
 */
#define kUpdateLog(log) [[DBHelper shareDBHelper] updateResultWithLog:log]
/**
 *  当前区域的所有配置信息(流程)
 */
#define kAreaConfigArray ([[DBHelper shareDBHelper] getAllConfig])


@class LogInfo;

@interface DBHelper : NSObject

kSingleTon_H(DBHelper)


#pragma mark - 获取当前区域指定视图的布局
- (NSArray *)getDeviceLayoutWithViewpointType:(ViewPointType)viewpointType;

#pragma mark - 为当前区域指定视图插入布局配置
- (BOOL)setDeviceLayoutWithViewpointType:(ViewPointType)viewpointType layouts:(NSArray *)layouts;

#pragma mark - 获取当前区域已配置的视角
- (NSArray *)getAllViewpointTypes;

#pragma mark - 删除当前区域指定视图的某个设备布局
- (BOOL)deleteDetailLayoutItemWithViewpointType:(ViewPointType)viewpointType deviceID:(NSString *)deviceID;

#pragma mark - 修改当前区域 指定视角的 全景图
- (BOOL)updateImageName:(NSString *)imageName viewpointType:(ViewPointType)viewpointType;

#pragma mark - 获取当前区域 指定视角 的全景图
- (NSString *)getImageNameWithViewpointType:(ViewPointType)viewpointType;

#pragma mark - 插入当前区域的日志
- (BOOL)insertLog:(LogInfo *)log;

#pragma mark - 查询当前区域的日志
- (NSArray *)getCurrentAreaLogWithPageSize:(NSInteger)size pageIndex:(NSInteger)index totolCount:(NSInteger *)totolCount;

#pragma mark - 更新操作日志的结果
- (BOOL)updateResultWithLog:(LogInfo *)log;

#pragma mark - 清空当前区域的日志
- (BOOL)clearLog;





#pragma mark - 插入当前区域的设备配置

#pragma mark - 删除当前区域的设备配置
- (BOOL)deleteConfigWithName:(NSString *)configName;

#pragma mark - 查询当前区域的所有设备配置
- (NSArray *)getAllConfig;

#pragma mark - 根据配置名获取配置详情
- (NSArray *)getDetailWithConfigName:(NSString *)configName;

#pragma mark - 根据设备配置名及所有设备列表,插入设备配置详情.[isReplace:替换或添加]
- (BOOL)insertDetail:(NSArray *)array intoConfigWithName:(NSString *)configName isReplace:(BOOL)isReplace;



@end
