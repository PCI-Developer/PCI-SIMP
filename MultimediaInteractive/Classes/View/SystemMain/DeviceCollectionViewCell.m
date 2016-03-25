//
//  DeviceCollectionViewCell.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "DeviceCollectionViewCell.h"

@implementation DeviceCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)changeImageViewWithStatus:(DeviceViewImageStatus)status
{
    // 设置当前状态应展示的image
    NSString *imageName = [NSString stringWithFormat:@"state_%lu", (unsigned long)status];
    
    _imageView.image = [UIImage imageNamed:imageName];
    // 根据状态,调整大小
    if (status != DeviceViewImageStatusForShouldConn) { // 普通大小
        self.contentView.transform = CGAffineTransformIdentity;
    } else {
        self.contentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }
}

- (void)setHighlighted:(BOOL)highlighted
{

}

/**
 *  不重写,点击cell之后,父类中会吧imageview的动画自动清除
 *
 *  @param selected <#selected description#>
 */
- (void)setSelected:(BOOL)selected
{

}



@end
