//
//  WFFProgressHud.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/11/13.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import "WFFProgressHud.h"

typedef enum {
    WFFProgressHudTypeNormal,
    WFFProgressHudTypeError,
    WFFProgressHudTypeSuccecss,
    WFFProgressHudTypeWarnning
} WFFProgressHudType;

@interface WFFProgressHud () {
    dispatch_source_t autoDismissTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *hudBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *hudImageView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@property (nonatomic, strong) UIImage *hudImage;

@property (nonatomic, assign) BOOL isAutoDismiss;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, assign) WFFProgressHudType type;
@end

@implementation WFFProgressHud

static int autoDismissDelay;


+ (void)showWithStatus:(NSString *)status
{
    [self showWithStatus:status onView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showErrorStatus:(NSString *)status
{
    [self showErrorStatus:status onView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showSuccessStatus:(NSString *)status
{
    [self showSuccessStatus:status onView:[UIApplication sharedApplication].keyWindow];
}


+ (void)showWarnningStatus:(NSString *)status
{
    [self showWarnningStatus:status onView:[UIApplication sharedApplication].keyWindow];
}









kSingleTon_M(WFFProgressHud)

- (instancetype)init
{
    WFFProgressHud *progressHud = (WFFProgressHud *)[[UINib nibWithNibName:@"WFFProgressHud" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
    [progressHud addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:progressHud action:@selector(tapGRAction:)]];
    progressHud.statusLabel.textColor = [UIColor colorFromHexRGB:@"#666666"];
    autoDismissDelay = 0;
    return progressHud;
}

- (void)tapGRAction:(UITapGestureRecognizer *)sender
{
    if (self.isAutoDismiss) {
        [self dismiss];
    }
}


+ (void)showErrorStatus:(NSString *)status onView:(UIView *)view
{
    [self showAutoDismissHudWithStatus:status type:WFFProgressHudTypeError onView:view];
}


+ (void)showSuccessStatus:(NSString *)status onView:(UIView *)view
{
    [self showAutoDismissHudWithStatus:status type:WFFProgressHudTypeSuccecss onView:view];
}

+ (void)showWarnningStatus:(NSString *)status onView:(UIView *)view
{
    [self showAutoDismissHudWithStatus:status type:WFFProgressHudTypeWarnning onView:view];
}




+ (void)showWithStatus:(NSString *)status onView:(UIView *)view
{
    WFFProgressHud *hud = [WFFProgressHud shareWFFProgressHud];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.isAutoDismiss = NO;
            hud.type = WFFProgressHudTypeNormal;
            hud.status = status;
            [hud updateUI];
            if (hud.superview != view) {
                [hud removeFromSuperview];
                hud.frame = view.bounds;
                [view addSubview:hud];
            }
            
        });
    } else {
        hud.isAutoDismiss = NO;
        hud.type = WFFProgressHudTypeNormal;
        hud.status = status;
        [hud updateUI];
        if (hud.superview != view) {
            [hud removeFromSuperview];
            hud.frame = view.bounds;
            [view addSubview:hud];
        }
    }
}


+ (void)showAutoDismissHudWithStatus:(NSString *)status type:(WFFProgressHudType)type onView:(UIView *)view
{
    WFFProgressHud *hud = [WFFProgressHud shareWFFProgressHud];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hud.superview != view) {
                [hud removeFromSuperview];
                hud.frame = view.bounds;
                [view addSubview:hud];
            }
            hud.isAutoDismiss = YES;
            hud.type = type;
            hud.status = status;
            [hud updateUI];
        });
    } else {
        if (hud.superview != view) {
            [hud removeFromSuperview];
            hud.frame = view.bounds;
            [view addSubview:hud];
        }
        hud.isAutoDismiss = YES;
        hud.type = type;
        hud.status = status;
        [hud updateUI];
    }
}




+ (void)dismiss
{
    WFFProgressHud *hud = [WFFProgressHud shareWFFProgressHud];
    [hud dismiss];
}

- (void)dismiss
{
    if (!self.superview) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeFromSuperview];
        });
    } else {
        [self removeFromSuperview];
    }
}

- (void)updateUI
{
    self.statusLabel.text = self.status;
    if (self.type == WFFProgressHudTypeNormal) {
        self.hudImageView.image = [UIImage imageNamed:@"hudLoading.png"];
        [self.hudImageView startRotation];
    } else if (self.type == WFFProgressHudTypeSuccecss) {
        self.hudImageView.transform = CGAffineTransformIdentity;
        self.hudImageView.image = [UIImage imageNamed:@"hudSuccess.png"];
        [self.hudImageView stopRotation];
        
    } else if(self.type == WFFProgressHudTypeError) {
        self.hudImageView.transform = CGAffineTransformIdentity;
        self.hudImageView.image = [UIImage imageNamed:@"hudError.png"];
        [self.hudImageView stopRotation];
    } else if (self.type == WFFProgressHudTypeWarnning) {
        self.hudImageView.transform = CGAffineTransformIdentity;
        self.hudImageView.image = [UIImage imageNamed:@"hudWarnning.png"];
        [self.hudImageView stopRotation];
    }
    
    if (self.isAutoDismiss) {
        [self autoDismiss];
    }
}

- (void)autoDismiss
{
    autoDismissDelay = 3;
//    if (autoDismissTimer == NULL) {
        autoDismissTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_timer(autoDismissTimer, dispatch_walltime(NULL, 0), 0.5f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(autoDismissTimer, ^{
            if (autoDismissDelay > 0.0f){
                autoDismissDelay -= 0.5f;
            } else { // == 0 -- 计时结束,停止计时,更改状态
                dispatch_source_cancel(autoDismissTimer);
                [weakSelf dismiss];
            }
        });
//    }
    dispatch_resume(autoDismissTimer);
}

@end
