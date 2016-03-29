//
//  PermissionCheckingViewController.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "PermissionCheckingViewController.h"
#import "SystemMainViewController.h"
#import "WFFCheckBox.h"
@interface PermissionCheckingViewController ()<UITextFieldDelegate>
{
    dispatch_source_t timer;
}
@property (weak, nonatomic) IBOutlet WFFCheckBox *remeberPwdCheckBox;
@property (weak, nonatomic) IBOutlet WFFCheckBox *autoLoginCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *anonLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)anonLoginButtonAction:(UIButton *)sender;
- (IBAction)loginButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userNameInputImageView;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIImageView *pwdInputImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintsWhileHideKeyboard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintsWhileShowKeyboard;

// 该界面刚进来并没有连接服务器,点击登陆才会开始连接服务器.连接到服务器后,需要做登陆操作.
// 当收到通知的时候,如果连接上服务器了.根据该字段决定是否登陆
@property (nonatomic, assign) BOOL needLoginAfterConnected;
@end

@implementation PermissionCheckingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    self.remeberPwdCheckBox.tintEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.autoLoginCheckBox.tintEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.needLoginAfterConnected = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedStateChanged:) name:NotificationDidConnectedStateChange object:nil];
    
    // 如果历史登陆用户存在
    if (kCurrentUser) {
        self.userNameTextField.text = kCurrentUser.name;
        self.remeberPwdCheckBox.selected = kCurrentUser.remeberPwd;
        self.autoLoginCheckBox.selected = kCurrentUser.autoLogin;
        if (kCurrentUser.remeberPwd) {
            self.pwdTextField.text = kCurrentUser.pwd;
        } else {
            self.pwdTextField.text = nil;
        }
        
        // 自动登陆
        // 界面第一次启动时,需要自动登陆.
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (kCurrentUser.autoLogin) {
                [self loginButtonAction:self.loginButton];
            }
        });
            
        
    } else {
        self.userNameTextField.text = nil;
        self.pwdTextField.text = nil;
        self.remeberPwdCheckBox.selected = NO;
        self.autoLoginCheckBox.selected = NO;
    }
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (timer != NULL) {
        dispatch_source_cancel(timer);
        timer = NULL;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)connectedStateChanged:(NSNotification *)sender
{
    if ([SocketManager shareSocketManager].state == SocketStateConnected) {
        if (self.needLoginAfterConnected) {
            [self loginButtonAction:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 键盘显示隐藏
- (void)keyboardDidChanged:(NSNotification *)sender
{
    NSDictionary* info = [sender userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];//得到鍵盤的高度
    if (CGRectGetMinY(kbRect) < kScreenHeight) { // 键盘显示
        [UIView animateWithDuration:0.25 animations:^{
            [self.view removeConstraint:self.constraintsWhileHideKeyboard];
            self.constraintsWhileShowKeyboard.constant = kbRect.size.height;
            [self.view layoutIfNeeded];
        }];
    } else { // 键盘隐藏
        [UIView animateWithDuration:0.25 animations:^{
            [self.view addConstraint:self.constraintsWhileHideKeyboard];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UITextFieldDelegate
// 键盘Return键的事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextField) {
        [self.pwdTextField becomeFirstResponder];
    } else {
        [self loginButtonAction:self.loginButton];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.userNameTextField) {
        self.userNameInputImageView.highlighted = YES;
        self.pwdInputImageView.highlighted = NO;
    }
    if (textField == self.pwdTextField) {
        self.pwdInputImageView.highlighted = YES;
        self.userNameInputImageView.highlighted = NO;
    }
}

#pragma mark - 控件事件
- (IBAction)anonLoginButtonAction:(UIButton *)sender {
    [Common shareCommon].isDemo = YES;
    __weak typeof(self) weakSelf = self;
    [[Common shareCommon] loginWithUserName:self.userNameTextField.text pwd:self.pwdTextField.text remeberPwd:self.remeberPwdCheckBox.selected autoLogin:self.autoLoginCheckBox.selected completionHandle:^(BOOL isSuccess, NSString *errorDescription) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                SystemMainViewController *nextVC = [[SystemMainViewController alloc] initWithNibName:@"SystemMainViewController" bundle:nil];
                [weakSelf presentViewController:nextVC animated:YES completion:nil];
            } else {
                [WFFProgressHud showErrorStatus:errorDescription];
            }
        });
        
    }];
}

#pragma mark - 5秒后检测是否连接到服务器,没有则认定网络配置错误
- (void)checkConn {
    if ([SocketManager shareSocketManager].state == SocketStateDisConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [WFFProgressHud showErrorStatus:@"无法连接到服务器,请检查网络配置后重试!"];
            [[SocketManager shareSocketManager] breakTcpSocket];
        });
    }
}

- (IBAction)remeberPwdCheckBoxValueChanged:(WFFCheckBox *)sender {
    if (!sender.selected) {
        if (self.autoLoginCheckBox.selected) {
            self.autoLoginCheckBox.selected = NO;
        }
    }
}

- (IBAction)autoLoginCheckBoxValueChanged:(WFFCheckBox *)sender {
    if (sender.selected) {
        if (!self.remeberPwdCheckBox.selected) {
            self.remeberPwdCheckBox.selected = YES;
        }
    }
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    __weak typeof(self) weakSelf = self;
    
    if (![self.userNameTextField.text length] || ![self.pwdTextField.text length]) {
        [WFFProgressHud showErrorStatus:@"用户名或密码不可为空"];
        return;
    }
    
    [Common shareCommon].isDemo = NO;
    
    if ([SocketManager shareSocketManager].state != SocketStateConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [WFFProgressHud showWithStatus:@"正在连接服务器..."];
        });
        [[SocketManager shareSocketManager] createTcpSocket];
        
        self.needLoginAfterConnected = YES;
        
        // 5秒后,判断是否连接到服务器. -- 界面消失后,即登陆成功,则停止定时器
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, (5 * NSEC_PER_SEC)), 1 * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(timer, ^{
            [weakSelf checkConn];
            weakSelf.needLoginAfterConnected = NO;
            dispatch_source_cancel(timer);
        });
        dispatch_resume(timer);

        
        return;
    }
    
    [WFFProgressHud showWithStatus:@"正在登陆..."];
    
    self.needLoginAfterConnected = NO;
    
    [[Common shareCommon] loginWithUserName:self.userNameTextField.text pwd:self.pwdTextField.text remeberPwd:self.remeberPwdCheckBox.selected autoLogin:self.autoLoginCheckBox.selected completionHandle:^(BOOL isSuccess, NSString *errorDescription) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [WFFProgressHud dismiss];
                SystemMainViewController *nextVC = [[SystemMainViewController alloc] initWithNibName:@"SystemMainViewController" bundle:nil];
                [weakSelf presentViewController:nextVC animated:YES completion:^{
                    
                }];
            } else {
                [WFFProgressHud showErrorStatus:errorDescription];
                [[Common shareCommon] logout];
            }
        });
        
    }];
}
- (IBAction)userNameInputImageViewTapGRAction:(UITapGestureRecognizer *)sender {
    [self.userNameTextField becomeFirstResponder];
}

- (IBAction)pwdInputImageViewTapGRAction:(UITapGestureRecognizer *)sender {
    [self.pwdTextField becomeFirstResponder];
}
#pragma mark - 登陆失败
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
