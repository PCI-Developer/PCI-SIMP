//
//  AutoSizeCollectionView.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/19.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "AutoSizeCollectionView.h"

@implementation AutoSizeCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGSize)intrinsicContentSize
{
    
    if (self.contentSize.width == 0) {
        return CGSizeMake(1, UIViewNoIntrinsicMetric);
    } else if (self.contentSize.width >= kScreenWidth) {
        return CGSizeMake(kScreenWidth, UIViewNoIntrinsicMetric);
    } else {
        return CGSizeMake(self.contentSize.width, UIViewNoIntrinsicMetric);
    }
}

@end
