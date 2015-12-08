//
//  SHMenuItem.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/11.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHMenuItem : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *gotoVC;
@property (nonatomic, copy) NSString *selectedImage;
@property (nonatomic, copy) NSString *function;
@end
