//
//  DBHelper.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/14.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "DBHelper.h"
#import "FMDB.h"

#import "DetaiLayoutOfAreaByViewpointType.h"
#import "Area.h"
#import "LogInfo.h"
#import "AreaConfig.h"
#import "DetailOfAreaConfig.h"

#define kNameForSave(name) [NSString stringWithFormat:@"%@,%@",(([[Common shareCommon] currentArea]).AreaID) ,name]
@interface DBHelper()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;


@end

@implementation DBHelper

static NSString *detailLayoutOfAreaByViewpointTypeTableName = @"detailLayoutOfAreaByViewpointType";
static NSString *logInfoTableName = @"LogInfo";
static NSString *areaConfigTableName = @"AreaConfig";
static NSString *detailOfAreaConfigTableName = @"DetailOfAreaConfig";


kSingleTon_M(DBHelper)

- (instancetype)init
{
    if (self = [super init]) {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[kDocumentFilePath stringByAppendingPathComponent:@"db.sqlite"]];
        [self createTable];
    }
    return self;
}

- (void)createTable
{
    NSString *sqlStringForDetailLayoutOfAreaByViewpointType = @"create table if not exists detailLayoutOfAreaByViewpointType(areaID,viewpointType int, deviceID, origin_X double, origin_Y double, size_Width double, size_Height double, rotationRadian double)";
    NSString *sqlStringForLogInfo = @"create table if not exists LogInfo(UEQP_ID, otherUEQP_ID, cmdType integer, value, type integer, createDate double, result integer, areaID, createUserID)";
    NSString *sqlStringForAreaConfig = @"create table if not exists AreaConfig(areaID, configName)";
    NSString *sqlStringForDetailOfAreaConfig = @"create table if not exists DetailOfAreaConfig(configName, deviceID, deviceData blob)";
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:sqlStringForDetailLayoutOfAreaByViewpointType]) {
            kLog(@"设备布局表创建成功");
        }
        if ([db executeUpdate:sqlStringForLogInfo]) {
            kLog(@"日志信息表创建成功");
        }
        if ([db executeUpdate:sqlStringForAreaConfig]) {
            kLog(@"配置表创建成功");
        }
        if ([db executeUpdate:sqlStringForDetailOfAreaConfig]) {
            kLog(@"配置详情表创建成功");
        }

    }];
}


#pragma mark - 获取当前区域指定视图的布局
- (NSArray *)getDeviceLayoutWithViewpointType:(ViewPointType)viewpointType
{
    NSString *sqlString = [NSString stringWithFormat:@"select * from %@ where areaID = ? and viewpointType = ?", detailLayoutOfAreaByViewpointTypeTableName];
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sqlString, kCurrentArea.AreaID, @(viewpointType)];
        while ([set next]) {
            DetaiLayoutOfAreaByViewpointType *detailLayout = [DetaiLayoutOfAreaByViewpointType new];
            detailLayout.areaID = [set stringForColumn:@"areaID"];
            detailLayout.viewpointType = [set intForColumn:@"viewpointType"];
            detailLayout.deviceID = [set stringForColumn:@"deviceID"];
            detailLayout.origin_X = [set doubleForColumn:@"origin_X"];
            detailLayout.origin_Y = [set doubleForColumn:@"origin_Y"];
            detailLayout.size_Width = [set doubleForColumn:@"size_Width"];
            detailLayout.size_Height = [set doubleForColumn:@"size_Height"];
            detailLayout.rotationRadian = [set doubleForColumn:@"rotationRadian"];
            [resultArray addObject:detailLayout];
        }
        [set close];
    }];
    return resultArray;
    
}

#pragma mark - 为当前区域指定视图插入布局配置
- (BOOL)setDeviceLayoutWithViewpointType:(ViewPointType)viewpointType layouts:(NSArray *)layouts
{
    __block BOOL flag = YES;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db executeUpdate:[NSString stringWithFormat:@"delete from %@ where areaID = :areaID and viewpointType = :viewpointType", detailLayoutOfAreaByViewpointTypeTableName] withParameterDictionary:@{@"areaID" : kCurrentArea.AreaID, @"viewpointType" : @(viewpointType)}]) {
            *rollback = YES;
            flag = NO;
            return ;
        }
        for (DetaiLayoutOfAreaByViewpointType *detailLayout in layouts) {
            if (![db executeUpdate:[NSString stringWithFormat:@"insert into %@(areaID,viewpointType, deviceID, origin_X, origin_Y, size_Width, size_Height, rotationRadian) values (?, ?, ?, ?, ?, ?, ?, ?)", detailLayoutOfAreaByViewpointTypeTableName]  withArgumentsInArray:@[detailLayout.areaID, @(detailLayout.viewpointType), detailLayout.deviceID, @(detailLayout.origin_X), @(detailLayout.origin_Y), @(detailLayout.size_Width), @(detailLayout.size_Height), @(detailLayout.rotationRadian)]]) {
                *rollback = YES;
                flag = NO;
                return ;
            }
        }

    }];
    
    return flag;
}

#pragma mark - 获取当前区域已配置的视角
- (NSArray *)getAllViewpointTypes
{
    
    NSString *sqlString = [NSString stringWithFormat:@"select * from %@ where areaID = ?", detailLayoutOfAreaByViewpointTypeTableName];
    NSMutableArray *resultArray = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sqlString, kCurrentArea.AreaID];
        while ([set next]) {
            ViewPointType viewpointType = [set intForColumn:@"viewpointType"];
            if (![resultArray containsObject:@(viewpointType)]) {
                
                [resultArray addObject:@(viewpointType)];
            }
        }
        [set close];
    }];
    
    return resultArray;
}

#pragma mark - 删除当前区域指定视图的某个设备布局
- (BOOL)deleteDetailLayoutItemWithViewpointType:(ViewPointType)viewpointType deviceID:(NSString *)deviceID
{
    __block BOOL flag;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where areaID = :areaID and deviceID = :deviceID and viewpointType = :viewpointType", detailLayoutOfAreaByViewpointTypeTableName] withParameterDictionary:@{@"areaID" : kCurrentArea.AreaID, @"deviceID" : deviceID, @"viewpointType" : @(viewpointType)}];
    }];
    return flag;
}
#pragma mark - 修改当前区域 指定视角的 全景图
- (BOOL)updateImageName:(NSString *)imageName viewpointType:(ViewPointType)viewpointType
{
    __block BOOL flag;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:[NSString stringWithFormat:@"update %@ set imageName = :imageName where areaID = :areaId and viewpointType = :viewpointType", detailLayoutOfAreaByViewpointTypeTableName] withParameterDictionary:@{@"imageName" : imageName, @"areaID" : kCurrentArea.AreaID, @"viewpointType" : @(viewpointType)}];
    }];
    return flag;
}

#pragma mark - 获取当前区域 指定视角 的全景图
- (NSString *)getImageNameWithViewpointType:(ViewPointType)viewpointType
{
    __block NSString *result = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"select imageName from %@ where areaID = :areaID and viewpointType = :viewpointType", detailLayoutOfAreaByViewpointTypeTableName] withParameterDictionary:@{@"areaID" : kCurrentArea.AreaID, @"viewpointType" : @(viewpointType)}];
        
        if ([set next]) {
            result = [set stringForColumn:@"imageName"];
        }
        [set close];
    }];
    return result;
}


#pragma mark - 日志
/*UEQP_ID, otherUEQP_ID, UEQP_IDs, cmdType integer, value, type integer, createDate)*/
#pragma mark 插入日志
- (BOOL)insertLog:(LogInfo *)log
{
    __block BOOL flag;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:[NSString stringWithFormat:@"insert into %@(UEQP_ID, otherUEQP_ID, cmdType, value, type, createDate, result, areaID, createUserID) values('%@', '%@', %lu, '%@', %lu, %f, %ld, '%@', '%@')",
                            logInfoTableName,
                            log.UEQP_ID ? log.UEQP_ID : @"",
                            log.otherUEQP_ID ? log.otherUEQP_ID : @"",
                            (unsigned long)log.cmdType,
                            log.value ? log.value : @"",
                            (unsigned long)log.type,
                            log.createDate,
                            (long)log.result,
                            log.areaID,
                                  log.createUserID]];
    }];
    
    return flag;
}
#pragma mark 查询日志
- (NSArray *)getCurrentAreaLogWithPageSize:(NSInteger)size pageIndex:(NSInteger)index totolCount:(NSInteger *)totolCount
{
    
    NSString *sqlString = [NSString stringWithFormat:@"select * from %@ where areaID = '%@' and type = 0 order by createDate desc limit %ld,%ld", logInfoTableName, kCurrentArea.AreaID, (long)(size * index), (long)size];
    NSString *sqlStringForGetCount = [NSString stringWithFormat:@"select count(*) count from %@ where areaID = '%@' and type = 0 order by createDate desc", logInfoTableName, kCurrentArea.AreaID];

    NSMutableArray *array = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sqlString];
        while ([set next]) {
            LogInfo *model = [LogInfo new];
            model.UEQP_ID = [set stringForColumn:@"UEQP_ID"];
            model.otherUEQP_ID = [set stringForColumn:@"otherUEQP_ID"];
            model.cmdType = [set intForColumn:@"cmdType"];
            model.value = [set stringForColumn:@"value"];
            model.type = [set intForColumn:@"type"];
            model.createDate = [set doubleForColumn:@"createDate"];
            model.result = [set intForColumn:@"result"];
            model.areaID = [set stringForColumn:@"areaID"];
            model.createUserID = [set stringForColumn:@"createUserID"];
            [array addObject:model];
        }
        
        NSInteger count = 0;
        set = [db executeQuery:sqlStringForGetCount];
        if ([set next]) {
            count = [set intForColumn:@"count"] ;
        }
        *totolCount = count;
        [set close];
    }];
    return array;
}


#pragma mark 更新操作日志的结果
- (BOOL)updateResultWithLog:(LogInfo *)log
{
    __block BOOL flag;
    NSString *sqlString = [NSString stringWithFormat:@"update %@ set result = %ld where createDate = %f", logInfoTableName, (long)log.result, log.createDate];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sqlString];
    }];
    
    return flag;
}

#pragma mark 清空日志
- (BOOL)clearLog
{
    __block BOOL flag;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where areaID = '%@'", logInfoTableName, kCurrentArea.AreaID]];
    }];
    
    return flag;
}



#pragma mark - 插入当前区域的设备配置
//(areaID, configName)";
//(configName, deviceID, deviceData blob)";
#pragma mark - 删除当前区域的设备配置
- (BOOL)deleteConfigWithName:(NSString *)configName
{
    __block BOOL flag = YES;
    // 对场景名称进行处理[带单引号的]
    if ([configName containsString:@"'"]) {
        configName = [configName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db executeUpdate:[NSString stringWithFormat:@"delete from %@ where configName = ?", areaConfigTableName] withArgumentsInArray:@[kNameForSave(configName)]]) {
            *rollback = YES;
            flag = NO;
            return ;
        }
        if (![db executeUpdate:[NSString stringWithFormat:@"delete from %@ where configName = ?", detailOfAreaConfigTableName] withArgumentsInArray:@[kNameForSave(configName)]]) {
            *rollback = YES;
            flag = NO;
            return;
        }
        
        
    }];
    
    return flag;
}

#pragma mark - 查询当前区域的所有设备配置
- (NSArray *)getAllConfig
{
    NSMutableArray *array = [NSMutableArray array];

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where areaid = ?", areaConfigTableName] withArgumentsInArray:@[kCurrentArea.AreaID]];
        while ([set next]) {
            AreaConfig *model = [AreaConfig new];
            model.areaID = [set stringForColumn:@"areaID"];
            model.configName = [[set stringForColumn:@"configName"] componentsSeparatedByString:@","].lastObject;
            [array addObject:model];
        }
        [set close];

    }];
    
    return array;
}

#pragma mark - 根据配置名获取配置详情
- (NSArray *)getDetailWithConfigName:(NSString *)configName
{
    // 对场景名称进行处理[带单引号的]
    if ([configName containsString:@"'"]) {
        configName = [configName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    
    NSMutableArray *array = [NSMutableArray array];
   [_dbQueue inDatabase:^(FMDatabase *db) {
       FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where configName = ?", detailOfAreaConfigTableName] withArgumentsInArray:@[kNameForSave(configName)]];
       while ([set next]) {
           DetailOfAreaConfig *model = [DetailOfAreaConfig new];
           model.configName = [[set stringForColumn:@"configName"] componentsSeparatedByString:@","].lastObject;
           model.deviceID = [set stringForColumn:@"deviceID"];
           model.configData = [set dataForColumn:@"deviceData"];
           [array addObject:model];
       }
       [set close];
   }];
    return array;
}

#pragma mark - 根据设备配置名及所有设备列表,插入设备配置详情.[若为替换.则只删除子表所有数据]
- (BOOL)insertDetail:(NSArray *)array intoConfigWithName:(NSString *)configName isReplace:(BOOL)isReplace
{
    // 对场景名称进行处理[带单引号的]
    if ([configName containsString:@"'"]) {
        configName = [configName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    
    __block BOOL flag = YES;
    // 先删除
    NSMutableArray *sqlArray = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"delete from %@ where configName = '%@'", detailOfAreaConfigTableName, kNameForSave(configName)],// 删除旧的子表
                                nil];
    if (!isReplace) {// 添加
        // 删除旧的主表
        [sqlArray addObject:[NSString stringWithFormat:@"delete from %@ where configName = '%@'", areaConfigTableName, kNameForSave(configName)]];
        // 添加新的主表
        [sqlArray addObject:[NSString stringWithFormat:@"insert into %@(areaID, configName) values('%@', '%@')", areaConfigTableName, kCurrentArea.AreaID, kNameForSave(configName)]];
    }

    // 开始事务,执行上述前置操作
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *sql in sqlArray) {
            if (![db executeUpdate:sql]) {
                flag = NO;
                *rollback = YES;
                return ;
            }
            
        }
        for (DetailOfAreaConfig *model in array) {
            if (![db executeUpdate:[NSString stringWithFormat:@"insert into %@(configName, deviceID, deviceData) values (?, ?, ?)", detailOfAreaConfigTableName] withArgumentsInArray:@[kNameForSave(model.configName), model.deviceID, model.configData]]) {
                flag = NO;
                *rollback = YES;
                return ;
            }
        }
    }];
    return flag;
}


@end
