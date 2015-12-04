//
//  SHStripeMenuActionDelegate.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SHMenuItem;
@protocol SHStripeMenuActionDelegate <NSObject>

@optional
- (void)stripeMenuItemSelected:(SHMenuItem *)item;

- (void)stripeMenuIndexSelected:(NSInteger)index;
@end
