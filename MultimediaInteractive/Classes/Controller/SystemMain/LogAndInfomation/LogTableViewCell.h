//
//  LogTableViewCell.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/25.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;

@end
