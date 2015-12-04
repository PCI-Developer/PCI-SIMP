//
//  SHStripeMenuViewController.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 26/04/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHStripeMenuViewController.h"
#import "SHMenuItem.h"
#import "UIApplication+AppDimensions.h"
#import "SHMenuCell.h"
#import <QuartzCore/QuartzCore.h>

@interface SHStripeMenuViewController () <UIGestureRecognizerDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView		*menuTableView;
@property (nonatomic, retain) NSMutableArray			*items;

@property (nonatomic, strong) UIView *backView;
@end

@implementation SHStripeMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		// Custom initialization
	}
	return self;
}

- (void)setupGestures
{
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePanel:)];

	[gestureRecognizer setDelegate:self];
	[self.view addGestureRecognizer:gestureRecognizer];
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeReceived:)];
	[panRecognizer setDelegate:self];
	[self.view addGestureRecognizer:panRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// ignore the touch
	if (touch.view.superview)
		if ([touch.view.superview isKindOfClass:[UITableViewCell class]])
			return NO;

	return YES;	// handle the touch
}

- (void)swipeReceived:(id)sender
{
	[self.delegate hideMenu];
}

- (void)hidePanel:(id)sender
{
	CGPoint location	= [(UITapGestureRecognizer *) sender locationInView:[[(UITapGestureRecognizer *) sender view] superview]];
	UIView	*tappedView = [self.view hitTest:location withEvent:nil];	// UITableViewCellContentView

	if ([tappedView isEqual:self.view])									// tappedView will be instance of UITableViewCellContentView on cliking menu item
		[self.delegate hideMenu];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	[self setupMenuItems];
	[self setupGestures];
    [self setTableView];
//    [self setUpBackView];
    [_menuTableView registerNib:[UINib nibWithNibName:@"SHMenuCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

//- (void)setUpBackView
//{
//    self.backView = [[UIView alloc] initWithFrame:_menuTableView.frame];
//    _backView.backgroundColor = [UIColor darkGrayColor];
//    
//    
//    [_backView addSubview:({
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_backView.bounds.size.width - 40, 0, 40, _backView.bounds.size.height)];
//        view.backgroundColor = [UIColor blackColor];
//        
//        UIView *subView = [[UIView alloc] initWithFrame:view.bounds];
//        subView.backgroundColorFromUIImage = [UIImage imageNamed:@"menuRightBg.png"];
//        
//        [view addSubview:subView];
//        view;
//    })];
//    
//    [self.view insertSubview:_backView atIndex:0];
//}

- (void)setTableView
{
	[_menuTableView setFrame:CGRectMake(0,
			([UIApplication currentSize].height - ROW_HEIGHT * [self.items count]) / 2,
			MENU_WIDTH,
			ROW_HEIGHT * [self.items count])];														// + 88
    _menuTableView.separatorColor = [UIColor blackColor];
//    _menuTableView.separatorInset = UIEdgeInsetsMake(0, 15 + 8, 0, 45 + 8);
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	_menuTableView.scrollEnabled = FALSE;
    
    // backView 跟随tableview
    _backView.frame = _menuTableView.frame;
    
}

- (void)setupMenuItems
{
	NSString	*filePath	= [[NSBundle mainBundle] pathForResource:@"menu_info" ofType:@"plist"];
	NSArray		*menuArray	= [[NSArray alloc] initWithContentsOfFile:filePath];

	self.items = [NSMutableArray array];

	for (NSDictionary *item in menuArray) {
		SHMenuItem *menuItem = [SHMenuItem new];
        [menuItem setValuesForKeysWithDictionary:item];
		[self.items addObject:menuItem];
	}

	// self.items = [NSMutableArray arrayWithArray:array];
	[self.menuTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.items count];
}


- (UITableViewCell *)tableView:(UITableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	UITableViewCell *cell = [self.menuTableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imageView	= (UIImageView *)[cell viewWithTag:101];
//    UILabel		*nameLabel	= (UILabel *)[cell viewWithTag:102];

		SHMenuItem *menuItem = [_items objectAtIndex:indexPath.row];
		imageView.image = [UIImage imageNamed:[menuItem image]];
//		nameLabel.text	= [menuItem name];
//	UIView *myView = [[UIView alloc] init];
//	myView.backgroundColor				= [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1];
//	_cellForMenu.backgroundView			= myView;
//	_cellForMenu.backgroundView.alpha	= .9;
//
//	CGRect frame = _cellForMenu.frame;
//	frame.size.width	= MENU_WIDTH;
//	_cellForMenu.frame	= frame;
//
//	if ([self.items count] == 1)
//	{
//		// Create the path (with only the top-right corner rounded)
//		UIBezierPath *maskPathRight = [UIBezierPath bezierPathWithRoundedRect	:_cellForMenu.bounds
//													byRoundingCorners			:UIRectCornerTopRight | UIRectCornerBottomRight
//													cornerRadii					:CGSizeMake(10.0, 10.0)];
//
//		// Create the shape layer and set its path
//		CAShapeLayer *maskLayerRight = [CAShapeLayer layer];
//		maskLayerRight.frame	= _cellForMenu.bounds;
//		maskLayerRight.path		= maskPathRight.CGPath;
//
//		_cellForMenu.layer.mask = maskLayerRight;
//	}
//	else
//	{
//		if ([indexPath row] == 0)
//		{
//			// Create the path (with only the top-right corner rounded)
//			UIBezierPath *maskPathTopRight = [UIBezierPath	bezierPathWithRoundedRect	:_cellForMenu.bounds
//															byRoundingCorners			:UIRectCornerTopRight
//															cornerRadii					:CGSizeMake(10.0, 10.0)];
//
//			// Create the shape layer and set its path
//			CAShapeLayer *maskLayerTopRight = [CAShapeLayer layer];
//			maskLayerTopRight.frame = _cellForMenu.bounds;
//			maskLayerTopRight.path	= maskPathTopRight.CGPath;
//
//			_cellForMenu.layer.mask = maskLayerTopRight;
//		}
//
//		if (indexPath.row == [self.items count] - 1)
//		{
//			// Create the path (with only the bottom-left corner rounded)
//			UIBezierPath *maskPathBottomRight = [UIBezierPath	bezierPathWithRoundedRect	:_cellForMenu.bounds
//																byRoundingCorners			:UIRectCornerBottomRight
//																cornerRadii					:CGSizeMake(10.0, 10.0)];
//
//			// Create the shape layer and set its path
//			CAShapeLayer *maskLayerBottomRight = [CAShapeLayer layer];
//			maskLayerBottomRight.frame	= _cellForMenu.bounds;
//			maskLayerBottomRight.path	= maskPathBottomRight.CGPath;
//
//			_cellForMenu.layer.mask = maskLayerBottomRight;
//		}
//
//		if (([indexPath row] > 0) && (indexPath.row < [self.items count] - 1))
//		{
//			// Create the path (with only the bottom-left corner rounded)
//			UIBezierPath *maskPathSquare = [UIBezierPath	bezierPathWithRoundedRect	:_cellForMenu.bounds
//															byRoundingCorners			:UIRectCornerAllCorners
//															cornerRadii					:CGSizeMake(0, 0)];
//
//			// Create the shape layer and set its path
//			CAShapeLayer *maskLayerSquare = [CAShapeLayer layer];
//			maskLayerSquare.frame	= _cellForMenu.bounds;
//			maskLayerSquare.path	= maskPathSquare.CGPath;
//
//			_cellForMenu.layer.mask = maskLayerSquare;
//		}
//	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// hide panel
	[_delegate hideMenu];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *imageView	= (UIImageView *)[cell viewWithTag:101];
    SHMenuItem *menuItem = [_items objectAtIndex:indexPath.row];
    
    if (menuItem.selectedImage && [menuItem.selectedImage length] > 0) {
        imageView.image = [UIImage imageNamed:[menuItem selectedImage]];
    }

    
	// send the selected menu item
    if ([_delegate respondsToSelector:@selector(itemSelected:)]) {
        
        [_delegate itemSelected:[_items objectAtIndex:indexPath.row]];
    }
    
    if ([_delegate respondsToSelector:@selector(indexSelected:)]) {
        [_delegate indexSelected:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *imageView	= (UIImageView *)[cell viewWithTag:101];
    SHMenuItem *menuItem = [_items objectAtIndex:indexPath.row];
    
    imageView.image = [UIImage imageNamed:[menuItem image]];

}

@end