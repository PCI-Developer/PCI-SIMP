//
//  WFFProgressHud.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/13.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFFProgressHud : UIView

kSingleTon_H(WFFProgressHud)

+ (void)showWithStatus:(NSString *)status;

+ (void)showErrorStatus:(NSString *)status;

+ (void)showSuccessStatus:(NSString *)status;

+ (void)showWarnningStatus:(NSString *)status;

+ (void)dismiss;
@end
