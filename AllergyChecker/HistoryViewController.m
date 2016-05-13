//
//  HistoryViewController.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/15.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "HistoryViewController.h"
#import "CustomCell.h"
#import "ResultViewController.h"
#import <CoreData/CoreData.h>

@interface HistoryViewController ()
@end


@implementation HistoryViewController

@synthesize tableView = tableView_;
NSArray *selectArray;
NSManagedObjectContext *context;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知設定の有無
    if([[UIApplication sharedApplication] scheduledLocalNotifications].count == 0){
        self.btnInfo.hidden = YES;
    }
    
    //カスタムセル設定
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"CustomCell"];
    
   context = [[NSManagedObjectContext alloc] init];
    
    //モデル定義
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HistoryEntity" withExtension:@"momd"];
    NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //永続化内容
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent:@"HistoryEntity.sqlite"]];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
    
    //ストレージ指定
    NSError *err = nil;
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&err]){
        NSLog(@"SQLiteエラー:%@", err);
        abort();
    }
    [context setPersistentStoreCoordinator:coordinator];
    NSError *error;
    
    //検索リクエスト
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *selectEntity = [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:context];
    [fetchRequest setIncludesSubentities:NO];
    [fetchRequest setEntity:selectEntity];
    
    //取得上限
    [fetchRequest setFetchBatchSize:10];
    
    //表示順
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    //検索実行
    selectArray = [context executeFetchRequest:fetchRequest error:&error];
    if (error != nil || selectArray.count == 0){
        NSLog(@"Data Nothing or Error %@", error);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
    
}

//セルセクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//セル個数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return selectArray.count;
}

//セル高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//セル作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifer = @"CustomCell";
    
    CustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifer];
    if(cell != nil){
        //結果
        NSManagedObject *obj = selectArray[indexPath.row];
        NSLog(@"id : %@", [obj valueForKey:@"id"]);
        
        float result = ([[obj valueForKey:@"h1"] floatValue] + [[obj valueForKey:@"l1"] floatValue] +
                        [[obj valueForKey:@"h2"] floatValue] + [[obj valueForKey:@"l2"] floatValue] +
                        [[obj valueForKey:@"h3"] floatValue] + [[obj valueForKey:@"l3"] floatValue]) / 6;
        cell.lblResult.text = [NSString stringWithFormat:@"%.1f", result];

        [cell.btnDelete addTarget:self action:@selector(touchDelete:event:) forControlEvents:UIControlEventTouchUpInside];
        
        //日付(更新日)
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
        [format setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        cell.lblDate.text = [format stringFromDate:[obj valueForKey:@"updateDate"]];
        
        //コメント
        cell.lblComment.text = [obj valueForKey:@"comment"];
        
        //セル背景色
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
    }
    return cell;
}


/*
 * セル選択時
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ResultViewController *resultView = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultView"];
    
    NSManagedObject *obj = selectArray[indexPath.row];
    
    
    NSArray *luminanceList = @[[NSString stringWithFormat:@"%@", [obj valueForKey:@"h1"]],
                                 [NSString stringWithFormat:@"%@", [obj valueForKey:@"h2"]],
                                 [NSString stringWithFormat:@"%@", [obj valueForKey:@"h3"]],
                                 [NSString stringWithFormat:@"%@", [obj valueForKey:@"l1"]],
                                 [NSString stringWithFormat:@"%@", [obj valueForKey:@"l2"]],
                                 [NSString stringWithFormat:@"%@", [obj valueForKey:@"l3"]]];

    NSArray *infoList = @[[obj valueForKey:@"comment"],
                            [NSString stringWithFormat:@"%.1f", [[obj valueForKey:@"temp"] doubleValue]],
                            [NSString stringWithFormat:@"%.1f", [[obj valueForKey:@"humidity"] doubleValue]],
                            [NSString stringWithFormat:@"%f", [[obj valueForKey:@"latitude"] floatValue]],
                            [NSString stringWithFormat:@"%f", [[obj valueForKey:@"longitude"] floatValue]]];

    resultView.registImage = [UIImage imageWithData:[obj valueForKey:@"image"]];
    resultView.updateID = [NSString stringWithFormat:@"%@", [obj valueForKey:@"id"]];
    
    //画面遷移・値セット
    [self presentViewController:resultView animated:NO completion:nil];
    [resultView setLuminanceLabel:luminanceList];
    [resultView setInfoLabel:infoList];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*
 * 削除ボタンタップ時
 */
- (void)touchDelete:(UIButton *)sender event:(UIEvent *)event {
    //タッチイベントからインデックスを取得
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    //検索リクエスト
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSManagedObject *managementObject = selectArray[indexPath.row];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", [managementObject valueForKey:@"id"]];
    [fetchRequest setPredicate:pred];
    
    NSEntityDescription *selectEntity = [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:context];
    [fetchRequest setIncludesSubentities:NO];
    [fetchRequest setEntity:selectEntity];
    
    //検索実行
    NSError *error = nil;
    NSArray *selectArray = [context executeFetchRequest:fetchRequest error:&error];
    
    if(error != nil || selectArray.count == 0){
        NSLog(@"Data Nothing or Error %@", error);
        
    }else{
        //削除実行
        NSManagedObject *deleteObject = selectArray.lastObject;
        [context deleteObject:deleteObject];
        
        if (![context save:&error]) {
            NSLog(@"Delete Error = %@", error);
        }
    }
    
    //再描画
    HistoryViewController *HistroyView = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryView"];
    [self presentViewController:HistroyView animated:NO completion:nil];

}


//全削除ボタンタップ時
- (IBAction)btnAllClear:(id)sender {

    NSString *msg = @"本当に全件削除してもよろしいですか？";
    if (NSClassFromString(@"UIAlertController")) {
        //iOS8以降
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self allDelete];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:nil]];
         
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        //iOS7以前
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:msg delegate:self
                                            cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい",nil];
        [alert show];
    }
}


/*
 * アラートボタンタップ時
 */
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //OKボタンタップ時
    if(buttonIndex == 1){
        [self allDelete];
    }
}


/*
 * 全件削除処理
 */
- (void) allDelete{
    //全件検索
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:context]];
    [fetchRequest setIncludesSubentities:NO];
    
    //検索実行
    NSError *error = nil;
    NSArray *selectArray = [context executeFetchRequest:fetchRequest error:&error];
    
    //全件削除
    for(NSManagedObject *obj in selectArray){
        [context deleteObject:obj];
    }
    if (![context save:&error]) {
        NSLog(@"All Delete Error = %@", error);
    }
    
    //再描画
    HistoryViewController *HistroyView = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryView"];
    [self presentViewController:HistroyView animated:NO completion:nil];
    
}


@end
