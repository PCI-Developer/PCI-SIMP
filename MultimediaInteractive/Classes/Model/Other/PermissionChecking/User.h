//
//  User.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface User : NSObject <NSCoding>

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *pwd;

@property (nonatomic, assign) NSTimeInterval timestampByLogin;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, assign) BOOL remeberPwd;

@property (nonatomic, assign) BOOL autoLogin;
@end
