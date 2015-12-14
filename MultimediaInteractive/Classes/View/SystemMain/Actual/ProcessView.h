//
//  ProcessView.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/12/10.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessView : UIView

/**
 *  方法内,有更新UI的..因此setter方法要在主线程
 */
@property (nonatomic, strong) NSArray *processArray;

/**
 *  错误提示信息
 */
@property (nonatomic, copy) NSString *errorDescription;

@property (nonatomic, copy) void(^doSomethingBlock)(NSString *selectedProcessID, BOOL isStart);
@end
