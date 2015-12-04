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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication*
    app = [UIApplication sharedApplication];
    
    __block
    UIBackgroundTaskIdentifier bgTask;
    
    bgTask
    = [app beginBackgroundTaskWithExpirationHandler:^{
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           
                           if
                               
                               (bgTask != UIBackgroundTaskInvalid)
                               
                           {
                               
                               bgTask
                               = UIBackgroundTaskInvalid;
                               
                           }
                           
                       });
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0),
                   ^{
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^{
                                          
                                          if
                                              
                                              (bgTask != UIBackgroundTaskInvalid)
                                              
                                          {
                                              
                                              bgTask
                                              = UIBackgroundTaskInvalid;
                                              
                                          }
                                          
                                      });
                       
                   });
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
