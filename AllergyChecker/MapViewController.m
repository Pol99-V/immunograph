//
//  MapViewController.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/14.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ResultViewController.h"

@interface MapViewController ()
@end

@implementation MapViewController

bool initFlg = true;
CLLocationCoordinate2D anotationLocation;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    //GPS設定・利用開始
    self.mapView.showsUserLocation = YES;
    [self.mapView setShowsUserLocation:YES];
    
    //位置情報初期化
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1000.0;
    anotationLocation = CLLocationCoordinate2DMake(0,0);
    
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
 * 位置情報更新時
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (initFlg){
        //現在地を基準とする。
        MKCoordinateSpan span = MKCoordinateSpanMake(0.02,0.02);
        MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        [self.mapView setRegion:region animated:YES];
    }
}


/*
 * 座標セット
 */
- (void)setMapLocation:(CLLocationCoordinate2D) location{
    //座標が登録されていない場合
    if (location.latitude == 0 && location.longitude == 0){
        //GPS利用開始
        if([CLLocationManager locationServicesEnabled]){
            //GPS利用開始
            [self.locationManager startUpdatingLocation];
        }
        
    }else{
        //登録座標を基点にマップ表示
        MKCoordinateSpan span = MKCoordinateSpanMake(0.02,0.02);
        MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
        [self.mapView setRegion:region animated:YES];
        
        //アノテーション作成
        MKPointAnnotation *point =[[MKPointAnnotation alloc] init];
        point.coordinate = location;
        [self.mapView addAnnotation:point];
        
        //ラベル表示
        self.lblLocation.text = [NSString stringWithFormat:@" 緯度:%f , 経度:%f" ,location.latitude , location.longitude];
        anotationLocation = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    }
    initFlg = NO;
}


/*
 * マップタップ時
 */
- (IBAction)mapViewDidTap:(UITapGestureRecognizer *)sender{
    //タップ座標取得
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint tapPoint = [sender locationInView:self.view];
        anotationLocation = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
        
        //前回のアノテーション削除
        [self.mapView removeAnnotations: self.mapView.annotations];
        
        //アノテーション作成
        MKPointAnnotation *point =[[MKPointAnnotation alloc] init];
        point.coordinate = anotationLocation;
        [self.mapView addAnnotation:point];
        
        self.lblLocation.text = [NSString stringWithFormat:@" 緯度:%f , 経度:%f" ,anotationLocation.latitude , anotationLocation.longitude];
    }
}


/*
 * OKボタンタップ時
 */
- (IBAction)btnOK:(id)sender {
    [self.delegate setLocation:anotationLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
 * クリアボタンタップ時
 */
- (IBAction)btnClear:(id)sender {
    [self.delegate setLocation:CLLocationCoordinate2DMake(0,0)];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
@end
