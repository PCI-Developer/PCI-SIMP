//
//  DeviceCollectionViewCell.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (void)changeImageViewWithStatus:(DeviceViewImageStatus)status;
@end
