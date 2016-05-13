//
//  AppDelegate.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioServices.h>
#import "ViewController.h"
#import "HistoryViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //ローカル通知設定の許可
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication]
         registerUserNotificationSettings:[UIUserNotificationSettings
                                           settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound
                                           categories:nil]];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    //アラート表示
    if (application.applicationState == UIApplicationStateActive){
        [self displayAlert];
    }
    
    //リセットタイム初期化
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:[NSString stringWithFormat:@"0,0,0,0"] forKey:@"ALERM_TIME"];
    
    //通知削除
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

- (void) displayAlert{
    AudioServicesPlaySystemSound(1002);
    NSString *msg = @"時間になりました。";
    if (NSClassFromString(@"UIAlertController")) {
        //iOS8以降
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alerm" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        //最前面のViewControllerを取得
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        //アラート表示
        [topController presentViewController:alertController animated:YES completion:nil];
        
    }else{
        //iOS7以前
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alerm" message:msg delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
