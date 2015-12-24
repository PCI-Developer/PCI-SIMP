//
//  AppDelegate.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 是否所有方向都支持 - 当UIImagePickerController出现时，支持所有方向。
@property (nonatomic, assign) BOOL isMaskAllForInterfaceOrientations;

@end

