//
//  ResultViewController.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "MapViewController.h"
#import "AnalysisView.h"

@protocol ResultDelegate;

@interface ResultViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate>

//画面遷移用
@property NSString *updateID;
@property UIImage *registImage;

@property CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIView *resultView;

//温度情報
- (IBAction)btnTemp:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblTemp;

//プレビュー画像
@property (strong, nonatomic) IBOutlet UIImageView *imgPreview;

//湿度情報
- (IBAction)btnHumidity:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblHumidity;

//場所情報
- (IBAction)btnMap:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblLat;
@property (strong, nonatomic) IBOutlet UILabel *lblLon;

//キーボード・ドラムロール非表示用
- (IBAction)singleTap:(id)sender;

//登録ボタン
- (IBAction)btnRegist:(id)sender;

//編集ボタン
- (IBAction)btnEdit:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

//戻るボタン
- (IBAction)btnReturn:(id)sender;

//結果ラベル
@property (weak, nonatomic) IBOutlet UILabel *lblNothing;
@property (strong, nonatomic) IBOutlet UILabel *lblH;
@property (strong, nonatomic) IBOutlet UILabel *lblL;

@property (strong, nonatomic) IBOutlet UILabel *lbl1;
@property (strong, nonatomic) IBOutlet UILabel *lbl1_1;
@property (strong, nonatomic) IBOutlet UILabel *lbl1_2;

@property (strong, nonatomic) IBOutlet UILabel *lbl2;
@property (strong, nonatomic) IBOutlet UILabel *lbl2_1;
@property (strong, nonatomic) IBOutlet UILabel *lbl2_2;

@property (strong, nonatomic) IBOutlet UILabel *lbl3;
@property (strong, nonatomic) IBOutlet UILabel *lbl3_1;
@property (strong, nonatomic) IBOutlet UILabel *lbl3_2;

@property (strong, nonatomic) IBOutlet UILabel *lblAVG;
@property (strong, nonatomic) IBOutlet UILabel *lblAVG_1;
@property (strong, nonatomic) IBOutlet UILabel *lblAVG_2;

@property (strong, nonatomic) IBOutlet UILabel *lblResult;

@property (strong, nonatomic) IBOutlet UITextView *txtComment;

@property (nonatomic, assign) id<ResultDelegate> delegate;


-(void)setLuminanceLabel:(NSArray *) luminanceList;
-(void)setInfoLabel:(NSArray *) infoList;

@end

