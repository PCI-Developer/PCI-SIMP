//
//  LogInfoViewController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/25.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "LogInfoViewController.h"
#import "LogInfo.h"
#import "LogTableViewCell.h"
#define kPageSize 20

@interface LogInfoViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *logArray;

@property (nonatomic, assign) NSInteger currentLogPage;
@property (weak, nonatomic) IBOutlet UITableView *logTableView;

@property (nonatomic, assign) NSInteger totalCountOfLog;
@end

@implementation LogInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentLogPage = 0;
    self.logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.logTableView registerNib:[UINib nibWithNibName:@"LogTableViewCell" bundle:nil] forCellReuseIdentifier:@"LogCell"];
    __weak typeof(self) weakSelf = self;
    self.logTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 消除底部没有更多状态
        [weakSelf.logTableView.footer resetNoMoreData];
        [weakSelf reloadDataWithType:Log completionHandle:^{
            [weakSelf.logTableView.header endRefreshing];
        }];
    }];
    
    self.logTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
       [weakSelf appendDataWithType:Log completionHandle:^{
           if (weakSelf.logArray.count == weakSelf.totalCountOfLog) {
               // 将底部设置为没有更多数据
               [weakSelf.logTableView.footer noticeNoMoreData];
           } else {
               [weakSelf.logTableView.footer endRefreshing];
           }
       }];
    }];
    
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.logTableView.header beginRefreshing];
}
#pragma mark - 数据相关
- (void)reloadDataWithType:(LogInfoType)type completionHandle:(void(^)())completionHandle
{
    self.currentLogPage = 0;
    [self loadDataWithType:type completionHandle:completionHandle];
    
}

- (void)appendDataWithType:(LogInfoType)type completionHandle:(void(^)())completionHandle
{
    self.currentLogPage++;
    [self loadDataWithType:type completionHandle:completionHandle];
}

- (void)loadDataWithType:(LogInfoType)type completionHandle:(void(^)())completionHandle
{
    if (type == Log) {// 日志
        
        if (_currentLogPage == 0) {
            self.logArray = [NSMutableArray arrayWithArray:[[DBHelper shareDBHelper] getCurrentAreaLogWithPageSize:kPageSize pageIndex:_currentLogPage totolCount:&_totalCountOfLog]];
        } else {
            NSArray *array = [[DBHelper shareDBHelper] getCurrentAreaLogWithPageSize:kPageSize pageIndex:_currentLogPage totolCount:&_totalCountOfLog];
            [self.logArray addObjectsFromArray:array];
        }
        [self.logTableView reloadData];
        if (completionHandle) {
            completionHandle();
        }
    }
}

- (void)clearDataWithType:(LogInfoType)type
{
    if (type == Log) {
        [[DBHelper shareDBHelper] clearLog];
        self.currentLogPage = 0;
        self.logArray = nil;
        [self.logTableView reloadData];
    }
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.logTableView) {
        return self.logArray.count;
    }
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.logTableView) {
        LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        LogInfo *model = self.logArray[indexPath.row];
        cell.contentLabel.text = [NSString stringWithFormat:@"%@", model];
        NSString *result = nil;
        if (model.result == -1) {
            result = @"未知";
        } else if (model.result == 0) {
            result = @"失败";
        } else {
            result = @"成功";
        }
        cell.resultLabel.text = result;
        cell.userLabel.text = [model.createUserID checkNull]  ? @"演示用户" : model.createUserID;
        cell.createDateLabel.text = [NSString stringWithDate:[NSDate dateWithTimeIntervalSince1970:model.createDate]];
        
        return cell;
    }
    
    return nil;
}


@end
