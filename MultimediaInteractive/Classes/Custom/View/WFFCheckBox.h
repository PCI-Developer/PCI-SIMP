//
//  WFFCheckBox.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/12/8.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  勾选框
 */
@interface WFFCheckBox : UIControl

@property (nonatomic, strong) IBInspectable UIImage *backgroundImage;

@property (nonatomic, strong) IBInspectable UIImage *leftImage;

@property (nonatomic, strong) IBInspectable UIImage *leftImageSelected;

@property (nonatomic, strong) IBInspectable UIImage *tintImage;

@property (nonatomic, strong) IBInspectable UIImage *tintImageSelected;

@property (nonatomic, copy) IBInspectable NSString *text;

@property (nonatomic, copy) IBInspectable NSString *textSelected;

@property (nonatomic, assign) UIEdgeInsets leftEdgeInsets;

@property (nonatomic, assign) UIEdgeInsets tintEdgeInsets;
@end
