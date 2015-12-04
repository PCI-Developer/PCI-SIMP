//
//  UIViewController+PresentAlertController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "UIViewController+PresentAlertController.h"

@implementation UIViewController (PresentAlertController)

#pragma mark - 弹出提示窗(当有textField时,再okhandle中返回. 当cancelhandle为空时,不显示取消按钮)
- (void)showAlertControllerWithTitle:(NSString *)title hasTextField:(BOOL)hasTextField okHandle:(void(^)(NSString *returnText))okHandle cancelHandle:(void (^)())cancelHandle
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (hasTextField) {
        [alertVC addTextFieldWithConfigurationHandler:nil];
    }
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = nil;
        if (alertVC.textFields.count > 0) {
            text = [alertVC.textFields[0] text];
        }
        if (okHandle) {
            okHandle(text);
        }
    }]];
    if (cancelHandle) {
        [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            cancelHandle();
        }]];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)showAlertControllerWithTitle:(NSString *)title
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}
@end
