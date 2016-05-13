//
//  ResultViewController.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "ResultViewController.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "HistoryViewController.h"
#import "AnalysisView.h"
#import "ViewController.h"
#import "math.h"


@interface ResultViewController()<MapViewDelegate, AnalysisDelegate>
@end


@implementation ResultViewController
@synthesize updateID;
@synthesize registImage;

UIPickerView *pickerView;
UIView *pickerBtnView;
UILabel *lblPoint;
NSString *touchBtnName;
NSPersistentStoreCoordinator *storeCoordinator;
bool isInit;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isInit = YES;
    //ラベル初期化
    [self initLabel];
    //ドラムロール作成
    [self makePicker];
    
    //編集モード判定
    if (updateID != nil){
        self.btnEdit.hidden = NO;
        
    }else{
        //現在座標表示
        [self startGPS];
        self.btnEdit.hidden = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    //画像設定
    self.imgPreview.image = registImage;
}

/*
 * 結果ラベル初期化(枠線表示)	
 */
- (void)initLabel {
    //セル設定(15)
    for (int i = 1; i <= 15; i++){
        UILabel *lbl = (UILabel *)[self.resultView viewWithTag:i];
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 0.5;
    }
    
    self.txtComment.layer.borderColor = [UIColor blackColor].CGColor;
    self.txtComment.layer.borderWidth = 1.0;
}


/*
 * 検査結果表示
 */
- (void)setLuminanceLabel:(NSArray *) luminanceList{
    
//    self.lbl1_1.text = luminanceList[0];
//    self.lbl2_1.text = luminanceList[1];
//    self.lbl3_1.text = luminanceList[2];
//    self.lbl1_2.text = luminanceList[3];
//    self.lbl2_2.text = luminanceList[4];
//    self.lbl3_2.text = luminanceList[5];

        self.lbl1_1.text = luminanceList[0];
        self.lbl1_2.text = luminanceList[1];

    float luminanceH = 0.0;
    float luminanceL = 0.0;

//    for (int i = 0; i < luminanceList.count; i++){
//        if (luminanceList.count / 2 > i){
//            luminanceH += [luminanceList[i] floatValue];
//        }else{
//            luminanceL += [luminanceList[i] floatValue];
//        }
//    }


    luminanceL = [luminanceList[0] floatValue];
    luminanceH = [luminanceList[1] floatValue];
    
    NSLog(@"lumiH:%f lumiL:%f",luminanceH,luminanceL);

    self.lblAVG_1.text = [NSString stringWithFormat:@"%.3f", luminanceH / (luminanceList.count / 2)];
    self.lblAVG_2.text = [NSString stringWithFormat:@"%.3f", luminanceL / (luminanceList.count / 2)];
//    self.lblResult.text = [NSString stringWithFormat:@"結果：%.1f", 1 - (luminanceH / luminanceL)];
    double a = 0.4;
    self.lblResult.text =
    [NSString stringWithFormat:@"%.3f",log10((double)((1.0-(float)luminanceH)/(1.0-(float)luminanceL)))];
//    NSLog(@"lumH:%f,lumL:%f",luminanceH,luminanceL);
}


/*
 * 追加情報表示
 */
- (void)setInfoLabel:(NSArray *) infoList{

    self.txtComment.text = infoList[0];
    if ([infoList[1] doubleValue] > 0){
        self.lblTemp.text = [infoList[1] stringByAppendingString:@"℃"];
    }
        
    if ([infoList[2] doubleValue] > 0){
        self.lblHumidity.text = [infoList[2] stringByAppendingString:@"%"];
    }
        
    if ([infoList[3] floatValue] > 0){
        self.lblLat.text = [@"緯度:" stringByAppendingString:infoList[3]];
    }
        
    if ([infoList[4] floatValue] > 0){
        self.lblLon.text = [@"経度:" stringByAppendingString:infoList[4]];
    }
}


/*
 * ドラムロール生成
 */
- (void)makePicker{
    //ドラムロール生成
    pickerView = [[UIPickerView alloc] init];
    pickerView.frame = CGRectMake(0, self.view.frame.size.height - 160, self.view.frame.size.width, 160);
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pickerView];
    
    //ボタンView
    pickerBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 160, self.view.frame.size.width, 30)];
    [self.view addSubview:pickerBtnView];
    
    //決定ボタン作成
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnDone.frame = CGRectMake(self.view.frame.size.width - 50, 0, 50, 20);
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    [pickerBtnView addSubview:btnDone];
    
    //キャンセルボタン作成
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnClear.frame = CGRectMake(0, 0, 50, 20);
    [btnClear setTitle:@"Clear" forState:UIControlStateNormal];
    [btnClear addTarget:self action:@selector(Clear:) forControlEvents:UIControlEventTouchUpInside];
    [pickerBtnView addSubview:btnClear];
    
    //小数点作成
    lblPoint = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 1.5, self.view.frame.size.height - 85, 15, 20)];
    lblPoint.text = @".";
    [self.view addSubview:lblPoint];
    
    //初期表示時は非表示
    lblPoint.hidden = YES;
    pickerView.hidden = YES;
    pickerBtnView.hidden = YES;
}


/*
 * 決定ボタンイベント
 */
- (void)Done:(id)sender{
    //ドラムロール選択値
    NSString *pickerString;
    
    int picker0 = (int)[pickerView selectedRowInComponent:0];
    int picker1 = (int)[pickerView selectedRowInComponent:1];
    int picker2 = (int)[pickerView selectedRowInComponent:2];
    
    if (picker0 <= 0){
        pickerString = [NSString stringWithFormat:@"%d.%d",picker1, picker2];
    }else{
        pickerString = [NSString stringWithFormat:@"%d%d.%d",picker0, picker1, picker2];
    }
    
    //対象ラベルに選択値を表示
    if ([touchBtnName isEqualToString:@"btnTemp"]){
        self.lblTemp.text = [pickerString stringByAppendingString:@"℃"];
    }else{
        self.lblHumidity.text = [pickerString stringByAppendingString:@"%"];
    }
    
    //ドラムロール非表示
    lblPoint.hidden = YES;
    pickerView.hidden = YES;
    pickerBtnView.hidden = YES;
}


/*
 * クリアボタンイベント
 */
- (void)Clear:(id)sender{
    //対象ラベルに選択値を表示
    if ([touchBtnName isEqualToString:@"btnTemp"]){
        self.lblTemp.text = @"--.-℃";
    }else{
        self.lblHumidity.text = @"--.-%";
    }
    
    //ドラムロール非表示
    lblPoint.hidden = YES;
    pickerView.hidden = YES;
    pickerBtnView.hidden = YES;
}


/*
 * ドラムロール列数
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
/*
 * ドラムロール行数
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}
/*
 * ドラムロール幅
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat width = 0.0;
    switch (component) {
        case 0: {
            width = self.view.frame.size.width / 3.5;
            break;
        }
        case 1: {
            width = self.view.frame.size.width / 3.5;
            break;
        }
        case 2: {
            width = self.view.frame.size.width / 3;
        }
    }
    return width;
}


/*
 * ドラムロール表示内容
 */
-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d", (int)row];
}


/*
 * 温度ボタンタップ時
 */
- (IBAction)btnTemp:(id)sender {
    touchBtnName = @"btnTemp";
    //ドラムロール表示
    lblPoint.hidden = NO;
    pickerView.hidden = NO;
    pickerBtnView.hidden = NO;
}


/*
 * 湿度ボタンタップ時
 */
- (IBAction)btnHumidity:(id)sender {
    touchBtnName = @"btnHumidity";
    //ドラムロール表示
    lblPoint.hidden = NO;
    pickerView.hidden = NO;
    pickerBtnView.hidden = NO;
}


/*
 * マップボタンタップ時
 */
- (IBAction)btnMap:(id)sender {
    
    MapViewController *mapView = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    mapView.delegate = self;
    
    //座標が無効でない場合、座標を渡して遷移
    CLLocationCoordinate2D location;
    if ([self.lblLat.text rangeOfString:@"--"].location == NSNotFound &&
            [self.lblLon.text rangeOfString:@"--"].location == NSNotFound){
        //文字置換
        NSString *strLat = [self.lblLat.text stringByReplacingOccurrencesOfString:@"緯度:" withString:@""];
        NSString *strLon = [self.lblLon.text stringByReplacingOccurrencesOfString:@"経度:" withString:@""];
        location = CLLocationCoordinate2DMake([strLat doubleValue], [strLon doubleValue]);
        
    }else{
        location = CLLocationCoordinate2DMake(0, 0);
    }
    
    //モーダルで開く
    [self presentViewController:mapView animated:YES completion:nil];
    [mapView setMapLocation:location];
}


/*
 * モーダル画面から値の受け取り
 */
- (void) setLocation:(CLLocationCoordinate2D)location{
    //場所ラベルの更新
    if (location.latitude !=0 && location.longitude != 0){
        self.lblLat.text = [NSString stringWithFormat:@"緯度:%f", location.latitude];
        self.lblLon.text = [NSString stringWithFormat:@"経度:%f", location.longitude];
    
    }else{
        self.lblLat.text = @"緯度:---.------";
        self.lblLon.text = @"経度:---.------";
    }
}


/*
 * 現在地取得
 */
- (void)startGPS{
    //位置情報初期化
    self.locationManager = [[CLLocationManager alloc] init];
    
    //GPS利用開始
    if([CLLocationManager locationServicesEnabled]){
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 100.0;
        [self.locationManager startUpdatingLocation];
    }
}


/*
 * 位置情報の使用可否
 */
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    //位置情報利用可能
    if (status == kCLAuthorizationStatusNotDetermined){
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    };
}


/*
 * 現在地を場所ラベルに表示（初回のみ）
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (isInit){
        //現在地をラベルに表示
        CLLocation *location = locations.lastObject;
        self.lblLat.text = [NSString stringWithFormat:@"緯度:%f", location.coordinate.latitude];
        self.lblLon.text = [NSString stringWithFormat:@"経度:%f", location.coordinate.longitude];
        isInit = NO;
    }
}


/*
 * 画面タップ時（キーボード・ドラムロール非表示用）
 */
- (IBAction)singleTap:(id)sender {
    [self.view endEditing:true];
    lblPoint.hidden = YES;
    pickerView.hidden = YES;
    pickerBtnView.hidden = YES;
}


//登録ボタンタップ時
- (IBAction)btnRegist:(id)sender {
    
    NSManagedObjectContext *context =[[NSManagedObjectContext alloc] init];
    
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
    
    
    NSError *error = nil;
    NSManagedObject *managedObject;
    
    //更新モード判定
    if (updateID != nil){
        //検索リクエスト
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *selectEntity = [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:context];
        [fetchRequest setIncludesSubentities:NO];
        [fetchRequest setEntity:selectEntity];

        //更新対象の検索条件
        NSPredicate *pred
        = [NSPredicate predicateWithFormat:@"id = %@", updateID];
        [fetchRequest setPredicate:pred];
        
        //検索実行
        NSArray *selectArray = [context executeFetchRequest:fetchRequest error:&error];
        
        if(error == nil && selectArray.count > 0){
            managedObject = selectArray.lastObject;
        }else{
            NSLog(@"更新対象の取得失敗");
        }
        
    }else{
        //ID取得
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *selectEntity = [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:context];
        [fetchRequest setIncludesSubentities:NO];
        [fetchRequest setEntity:selectEntity];
        
        //ID降順
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
        
        //検索・ID取得
        int newID = 0;
        NSArray *selectArray = [context executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil){
            NSLog(@"Data Get Error");
            return;
        }
        
        if (selectArray.count != 0){
            newID = [[selectArray[0] valueForKey:@"id"] intValue] + 1;
        }
        //登録エンテティ作成
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryEntity" inManagedObjectContext:context];
        
        //ID、画像、登録日は新規の場合のみ登録
        [managedObject setValue:@(newID) forKey:@"id"];
        [managedObject setValue:UIImagePNGRepresentation(registImage) forKey:@"image"];
        [managedObject setValue:[NSDate date] forKey:@"registDate"];
    }
    
    //登録・更新内容
    [managedObject setValue:@([self.lbl1_1.text intValue]) forKey:@"h1"];
    [managedObject setValue:@([self.lbl1_2.text intValue]) forKey:@"l1"];
    [managedObject setValue:@([self.lbl2_1.text intValue]) forKey:@"h2"];
    [managedObject setValue:@([self.lbl2_2.text intValue]) forKey:@"l2"];
    [managedObject setValue:@([self.lbl3_1.text intValue]) forKey:@"h3"];
    [managedObject setValue:@([self.lbl3_2.text intValue]) forKey:@"l3"];
    [managedObject setValue:self.txtComment.text forKey:@"comment"];
    [managedObject setValue:@([[self.lblTemp.text substringToIndex:(self.lblTemp.text.length-1)] floatValue]) forKey:@"temp"];
    [managedObject setValue:@([[self.lblHumidity.text substringToIndex:(self.lblHumidity.text.length-1)] floatValue]) forKey:@"humidity"];
    [managedObject setValue:@([[self.lblLat.text stringByReplacingOccurrencesOfString:@"緯度:" withString:@""] doubleValue]) forKey:@"latitude"];
    [managedObject setValue:@([[self.lblLon.text stringByReplacingOccurrencesOfString:@"経度:" withString:@""] doubleValue]) forKey:@"longitude"];
    [managedObject setValue:[NSDate date] forKey:@"updateDate"];
    
    //結果履歴遷移
    ViewController *topView = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:topView animated:NO completion:nil];
    
    //登録・更新実行
    if(![context save:&error]){
        [self showAlert:error.description];
    }else{
        [self showAlert:@"登録が完了しました。"];
    }

}


/*
 * 編集ボタンタップ時
 */
- (IBAction)btnEdit:(id)sender {
    AnalysisView *analysisView = [self.storyboard instantiateViewControllerWithIdentifier:@"AnalysisView"];
    analysisView.delegate = self;
    
    analysisView.updateID = updateID;
    analysisView.baseImage = registImage;
    [self presentViewController:analysisView animated:NO completion:nil];
}


/*
 * メッセージ表示
 */
- (void)showAlert:(NSString *) msg{
    if (NSClassFromString(@"UIAlertController")) {
        //iOS8以降
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        //iOS7以前
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


/*
 * 遷移元へ戻る
 */
- (IBAction)btnReturn:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
