//
//  ProcessView.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/12/10.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "ProcessView.h"
#import "Process.h"
@interface ProcessView ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *processDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

- (IBAction)startProcessButtonAction:(UIButton *)sender;
- (IBAction)stopProcessButtonAction:(UIButton *)sender;

@property (nonatomic, copy) NSString *selectedProcessID;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation ProcessView


- (instancetype)init
{
    self = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)setProcessArray:(NSArray *)processArray
{
    if (!processArray || [processArray count] == 0) {
        [self updateUIByShow:NO];
        
        self.errorDescription = !processArray ? @"加载中..." : @"服务器没有配置流程!";
        return;
    }
    [self updateUIByShow:YES];
    if (_processArray != processArray) {
        _processArray = nil;
        _processArray = processArray;
        [self.tableView reloadData];
    }
}

- (void)setErrorDescription:(NSString *)errorDescription
{
    if (_errorDescription != errorDescription) {
        _errorDescription = nil;
        _errorDescription = [errorDescription copy];
        self.infoLabel.text = errorDescription;
    }
}

- (void)updateUIByShow:(BOOL)isShow
{
    self.mainView.hidden = !isShow;
    self.infoLabel.hidden = isShow;
}

- (IBAction)startProcessButtonAction:(UIButton *)sender {
    if (_doSomethingBlock) {
        _doSomethingBlock(self.selectedProcessID, YES);
    }
}

- (IBAction)stopProcessButtonAction:(UIButton *)sender {
    if (_doSomethingBlock) {
        _doSomethingBlock(self.selectedProcessID, NO);
    }
}

#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _processArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = [_processArray[indexPath.row] processName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedProcessID = [_processArray[indexPath.row] processId];
    self.processDescriptionLabel.text = [_processArray[indexPath.row] processInfo];
}
@end
