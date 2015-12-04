//
//  DetailOfAreaConfig.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/30.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailOfAreaConfig : NSObject

@property (nonatomic, copy) NSString *configName;

@property (nonatomic, copy) NSString *deviceID;

/**
 *  OC中为NSDictionary.对应设备的配置信息.此处仅为方便本地存储
 */
@property (nonatomic, strong) NSData *configData;

@end
