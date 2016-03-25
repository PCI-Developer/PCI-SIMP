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

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow) {// 每次cell即将出现都会执行方法 。 此处主要修复切换到其他vc再切回来时（切换到其他vc会停止当前vc的imageview的动画），因为当前actualvc没有移除，当前的cell之前走过cellfor代理，不会再重新走，导致不会再重新获取cell的imageview的动画组并且开启动画。 出现cell的imageview不显示内容
        if ([self.deviceImageView.animationImages count] > 0 && !self.deviceImageView.isAnimating) { // 包含动画图片而动画已经停止，则重新开启
            [self.deviceImageView startAnimating];
        }
    }
}
@end
