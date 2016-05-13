//
//  AlermViewController.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/25.
//  Copyright © 2015年 prage. All rights reserved.
//

#import "AlermViewController.h"

@interface AlermViewController ()

@end

@implementation AlermViewController

NSTimer *timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知設定されている場合、残り時間を表示
    NSArray *notification = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if(notification.count != 0){
        UILocalNotification *notificationInfo = notification[0];
        int limit = (int)[notificationInfo.fireDate timeIntervalSinceDate:[NSDate date]];
        
        [self.pickerMin selectRow:(int)(limit / 60) % 60 inComponent:0 animated:NO];
        [self.pickerSec selectRow:(int)limit % 60 inComponent:0 animated:NO];
        
        //タイマーを再設定
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                               selector:@selector(countDown:) userInfo:nil repeats:YES];
        [timer fire];
        [self.btnStart setImage:[UIImage imageNamed:@"btnStop"] forState:UIControlStateNormal];
    }
    
}


/*
 * ドラムロール列数
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
/*
 * ドラムロール行数
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 60;
}

/*
 * ドラムロール表示内容
 */
-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d", (int)row];
}


/*
 * スタートボタンタップ時
 */
- (IBAction)btnStart:(id)sender {
    
    //設定済みの通知をキャンセル
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //タイマーが存在すれば停止する
    if(timer != nil && [timer isValid]){
        [timer invalidate];
        NSLog(@"Stop");
        [self.btnStart setImage:[UIImage imageNamed:@"btnStart"] forState:UIControlStateNormal];
        return;
    }
    
    //設定時間の取得
    int min_0 = (int)[self.pickerMin selectedRowInComponent:0];
    int sec_0 = (int)[self.pickerSec selectedRowInComponent:0];
    
    //設定アラームを保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d,%d",min_0, sec_0] forKey:@"ALERM_TIME"];

    //通知設定
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:min_0 * 60 + sec_0 -1];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = @"時間になりました。";
    
    //1分前通知
    if (min_0 > 1){
        UILocalNotification *notification1min = [[UILocalNotification alloc] init];
        notification1min.fireDate = [NSDate dateWithTimeIntervalSinceNow:(min_0 - 1) * 60 + sec_0 -1];
        notification1min.timeZone = [NSTimeZone defaultTimeZone];
        notification1min.alertBody = @"検査完了まであと1分です。";
        NSLog(@"%@", [NSDate dateWithTimeIntervalSinceNow:(min_0 - 1) * 60 + sec_0 -1]);
    }
        
    //通知登録
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    //カウントダウン開始
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                           selector:@selector(countDown:) userInfo:nil repeats:YES];
    [timer fire];
    
    [self.btnStart setImage:[UIImage imageNamed:@"btnStop"] forState:UIControlStateNormal];
 }


/*
 * カウントダウン
 */
- (void) countDown:(NSTimer *)timer{
    
    int min_0 = (int)[self.pickerMin selectedRowInComponent:0];
    int sec_0 = (int)[self.pickerSec selectedRowInComponent:0];
    
    if (sec_0 != 0){
        [self.pickerSec selectRow:sec_0 - 1 inComponent:0 animated:YES];
    
    }else{
        if (min_0 != 0){
            [self.pickerMin selectRow:min_0 - 1 inComponent:0 animated:YES];
            [self.pickerSec selectRow:59 inComponent:0 animated:YES];
            
        }else{
            [self.btnStart setImage:[UIImage imageNamed:@"btnStart"] forState:UIControlStateNormal];
            [timer invalidate];
        }
    }
}


/*
 * 通知設定
 */
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    return YES;
}


/*
 * リセットボタンタップ時
 */
- (IBAction)btnReset:(id)sender {
    //設定済みの通知をキャンセル
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [timer invalidate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *beforTime = [defaults stringForKey:@"ALERM_TIME"];

    NSArray *time = [beforTime componentsSeparatedByString:@","];
    [self.pickerMin selectRow:[time[0] intValue] inComponent:0 animated:NO];
    [self.pickerSec selectRow:[time[1] intValue] inComponent:0 animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
