//
//  AppDelegate.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "AppDelegate.h"
#import "PermissionCheckingViewController.h"
@interface AppDelegate ()
{
    int _timeInterval;
    UIBackgroundTaskIdentifier _bgTask;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [DBHelper shareDBHelper];
//    
//    [Common shareCommon];
    

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:kScreenBounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[PermissionCheckingViewController alloc] initWithNibName:@"PermissionCheckingViewController" bundle:nil];
    
    [self.window makeKeyAndVisible];
    

    kLog(@"%@", NSTemporaryDirectory());
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//程序已经进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 刚进入后台，应用有几秒的保存时间。因此在1秒内足够进入定时器开启后台任务。
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}
#pragma mark -- 无限后台 -- 定时器无限创建后台任务。
-(void)timerAction:(NSTimer *)timer
{
    _timeInterval++;
    if(_timeInterval == 500)//后台任务的生命同期为600s
    {
        UIApplication *application = [UIApplication sharedApplication];
        //结束旧的后台任务
        if (_bgTask != UIBackgroundTaskInvalid) { // 有效的后台任务
            dispatch_async(dispatch_get_main_queue(), ^{
                [application endBackgroundTask:_bgTask];
            });
        }
        
        //开启一个新的后台任务
        _bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
              // 当应用程序留给后台的时间快要到结束时（应用程序留给后台执行的时间是有限的）， 这个Block块将被执行
            dispatch_async(dispatch_get_main_queue(), ^{
                [application endBackgroundTask:_bgTask];
            });
        }];
        _timeInterval = 0;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWillEnterForeground object:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (_isMaskAllForInterfaceOrientations) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}


@end
