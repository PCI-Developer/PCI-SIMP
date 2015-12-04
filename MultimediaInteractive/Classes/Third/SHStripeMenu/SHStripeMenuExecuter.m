//
//  SHStripeMenuExecuter.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHStripeMenuExecuter.h"
#import "SHStripeMenuViewController.h"
#import "SHLineView.h"
#import "UIApplication+AppDimensions.h"

#define STRIPE_WIDTH (self.lineView.bounds.size.width)
#define STRIPE_HEIGHT (self.lineView.bounds.size.height)
@interface SHStripeMenuExecuter () <UIGestureRecognizerDelegate, SHStripeMenuDelegate>

@property (nonatomic, strong) SHStripeMenuViewController					*stripeMenuViewController;
@property (nonatomic, assign) UIViewController <SHStripeMenuActionDelegate> *rootViewController;
@property (nonatomic, strong) UIView										*lineView;
@property (nonatomic, assign) BOOL											showingStripeMenu;

@end

@implementation SHStripeMenuExecuter

- (void)setupToParentView:(UIViewController <SHStripeMenuActionDelegate> *)rootViewController
{
	self.rootViewController = rootViewController;
	[self setStripes];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)setupToParentView:(UIViewController<SHStripeMenuActionDelegate> *)rootViewController withLineView:(UIView *)lineView
{
    self.rootViewController = rootViewController;
    self.lineView = lineView;
    [self setStripes];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStripes
{
	[self createMenuView];
	[self setStripesView];
}

- (void)createMenuView
{
    if (_stripeMenuViewController == nil)
    {
        self.stripeMenuViewController			= [[SHStripeMenuViewController alloc] initWithNibName:@"SHStripeMenuViewController" bundle:nil];
        self.stripeMenuViewController.delegate	= self;
        [_rootViewController.view addSubview:self.stripeMenuViewController.view];
        [_stripeMenuViewController didMoveToParentViewController:_rootViewController];
        // XIB创建的.如果根据rootViewController的宽度来平移到左侧的时候,此时XIB宽度并非实际宽度.会导致左侧存在部分遮罩层
        _stripeMenuViewController.view.frame = CGRectMake(-kScreenWidth, 0, _rootViewController.view.frame.size.width, _rootViewController.view.frame.size.height);
    }
}

- (void)setStripesView
{
	NSString	*filePath		= [[NSBundle mainBundle] pathForResource:@"menu_info" ofType:@"plist"];
	NSArray		*menuArray		= [[NSArray alloc] initWithContentsOfFile:filePath];
	NSInteger	numberOfItems	= [menuArray count];

	if (_lineView == nil)
	{
		_lineView = [[SHLineView alloc] initWithFrame:CGRectMake(0, ([UIApplication currentSize].height - ROW_HEIGHT * numberOfItems) / 2, 10, ROW_HEIGHT * numberOfItems)];
		[_rootViewController.view addSubview:_lineView];
		_lineView.backgroundColor = [UIColor clearColor];
	}
    else {
        if (!_lineView.superview) {
            [_rootViewController.view addSubview:_lineView];
        }
		_lineView.frame = CGRectMake(0, ([UIApplication currentSize].height - STRIPE_HEIGHT) / 2, STRIPE_WIDTH, STRIPE_HEIGHT);
    }
	[_rootViewController.view bringSubviewToFront:_lineView];

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stripesTapped:)];
	[tapRecognizer setDelegate:self];
	[_lineView addGestureRecognizer:tapRecognizer];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(stripesSwiped:)];
	[panRecognizer setDelegate:self];
	[_lineView addGestureRecognizer:panRecognizer];
}

- (void)stripesTapped:(id)sender
{
	[self showStripeMenu];
}

- (void)stripesSwiped:(id)sender
{
	// Show menu only when swiped to right
	CGPoint velocity = [(UIPanGestureRecognizer *) sender velocityInView:[sender view]];

	if ([(UIPanGestureRecognizer *) sender state] == UIGestureRecognizerStateEnded)
		if (velocity.x > 0)
			[self showStripeMenu];
	// gesture went right
}


- (UIView *)getMenuView
{
	[self createMenuView];
	// set up view shadows
	UIView *view = self.stripeMenuViewController.view;

	return view;
}

- (void)hideStripeMenu
{
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_stripeMenuViewController.view.frame = CGRectMake (-_stripeMenuViewController.view.frame.size.width, 0, _stripeMenuViewController.view.frame.size.width, _stripeMenuViewController.view.frame.size.height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{
				self.showingStripeMenu = FALSE;
			}
		}
	];
	// show stripes
	[self setStripesView];
	CGRect lineViewFrame = _lineView.frame;

	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_lineView.frame = CGRectMake (0, lineViewFrame.origin.y, lineViewFrame.size.width, lineViewFrame.size.height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{}
		}
	];
}

- (void)showStripeMenu
{
	UIView *childView = [self getMenuView];

	[_rootViewController.view bringSubviewToFront:childView];
	// show menu
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_stripeMenuViewController.view.frame = CGRectMake (0, 0, [UIApplication currentSize].width, [UIApplication currentSize].height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{
				self.showingStripeMenu = TRUE;
			}
		}
	];
	// hide stripes
	[self setStripesView];
	CGRect lineViewFrame = _lineView.frame;

	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_lineView.frame = CGRectMake (-STRIPE_WIDTH, lineViewFrame.origin.y, lineViewFrame.size.width, lineViewFrame.size.height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{}
		}
	];
}

- (void)hideMenu
{
	[self hideStripeMenu];
}

- (void)itemSelected:(SHMenuItem *)item
{
    if ([_rootViewController respondsToSelector:@selector(stripeMenuItemSelected:)]) {
        
        [_rootViewController stripeMenuItemSelected:item];
        [self setStripesView];
    }
}

- (void)indexSelected:(NSInteger)index
{
    if ([_rootViewController respondsToSelector:@selector(stripeMenuIndexSelected:)]) {
        
        [_rootViewController stripeMenuIndexSelected:index];
        [self setStripesView];
    }
}

- (void)didRotate:(NSNotification *)notification
{
	if (!self.showingStripeMenu)
		[self setStripesView];
	[_stripeMenuViewController setTableView];
}

@end