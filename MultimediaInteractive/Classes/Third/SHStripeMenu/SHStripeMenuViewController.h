//
//  SHStripeMenuViewController.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 26/04/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMenuItem.h"

#define MENU_WIDTH		100
#define ROW_HEIGHT		84
#define SLIDE_TIMING	.25

@protocol SHStripeMenuDelegate <NSObject>

@required
- (void)itemSelected:(SHMenuItem *)item;
- (void)indexSelected:(NSInteger)index;
- (void)hideMenu;

@end

@interface SHStripeMenuViewController : UIViewController

@property (nonatomic, assign) id <SHStripeMenuDelegate> delegate;
- (void)setTableView;

@end