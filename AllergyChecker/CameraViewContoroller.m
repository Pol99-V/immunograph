//
//  CameraViewContoroller.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "CameraViewContoroller.h"
#import "AnalysisView.h"
#import "AVFoundation/AVFoundation.h"

@interface CameraViewContoroller()

@end


@implementation CameraViewContoroller
@synthesize captureSession, imageOutput, previewLayer;

bool ContinueFlg = NO;    //連続撮影フラグ
AVCaptureDeviceInput *deviceInput;  //カメラ
AVCaptureStillImageOutput *imageOutput;    //出力画像
AVCaptureSession *session;  //キャプチャセッション
UIView *previewView;
AVCaptureConnection *captureConnection;


#define INDICATOR_RECT_SIZE 50.0


- (void)viewDidLoad {
    [super viewDidLoad];
    ContinueFlg = NO;
    [self.viewGuide.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.viewGuide.layer setBorderWidth:1.0];
    [self.btnContinue setImage:[UIImage imageNamed:@"btnContinueOn"] forState:UIControlStateNormal];
    
    //初期化
    NSError *error = nil;
    session = [[AVCaptureSession alloc] init];
    
    //カメラビューを再背面に表示
    previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:previewView];
    [self.view sendSubviewToBack:previewView];
    
    [session setSessionPreset:AVCaptureSessionPresetMedium];
    
    //カメラ入力
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    [session addInput:deviceInput];
    
    //カメラキャプチャ出力
    imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:imageOutput];
    
    //キャプチャレイヤ作成
    AVCaptureVideoPreviewLayer *captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureLayer.frame = self.view.bounds;
    captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //カメラ向き設定
    [session beginConfiguration];
    captureConnection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
    [session commitConfiguration];
    
    //キャプチャレイヤ表示
    [previewView.layer addSublayer:captureLayer];
    [session startRunning];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice* videoCaptureDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    NSError* error = nil;
    AVCaptureDeviceInput* videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];

//     if (videoInput) {
//        [self.captureSession addInput:videoInput];
//        [self.captureSession beginConfiguration];
//        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
//        [self.captureSession commitConfiguration];
//        
//        NSError* error = nil;
//        if ([videoCaptureDevice lockForConfiguration:&error]) {
//            if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
//                videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
//                
//            } else if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//                videoCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
//            }
//            
//
//            if ([videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
//                videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
//            } else if ([videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
//                videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
//            }
//            
//            if ([videoCaptureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
//                videoCaptureDevice.flashMode = AVCaptureFlashModeAuto;
//            }
//            
//            [videoCaptureDevice unlockForConfiguration];
//            
//
//        } else {
//            NSLog(@"%s|[ERROR] %@", __PRETTY_FUNCTION__, error);
//        }
//        
////        self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
////        [self.captureSession addOutput:self.imageOutput];
////        for (AVCaptureConnection* connection in self.imageOutput.connections) {
////            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
////        }
//        
////        self.previewLayer =
////        [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
//////        self.previewLayer.automaticallyAdjustsMirroring = NO;
////        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////        self.previewLayer.frame = self.view.bounds;
////        [self.view.layer addSublayer:self.previewLayer];
////        
////        [self.captureSession startRunning];
//        
//        // add layer
//        self.indicatorLayer = [CALayer layer];
//        self.indicatorLayer.borderColor = [[UIColor whiteColor] CGColor];
//        self.indicatorLayer.borderWidth = 1.0;
//        self.indicatorLayer.frame = CGRectMake(self.view.bounds.size.width/2.0 - INDICATOR_RECT_SIZE/2.0,
//                                               self.view.bounds.size.height/2.0 - INDICATOR_RECT_SIZE/2.0,
//                                               INDICATOR_RECT_SIZE,
//                                               INDICATOR_RECT_SIZE);
//        self.indicatorLayer.hidden = NO;
//        [self.view.layer addSublayer:self.indicatorLayer];
//        
//        
//        // add gesture
//        UIGestureRecognizer* gr = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self action:@selector(didTapGesture:)];
//        [self.view addGestureRecognizer:gr];
//    }
}


/*
 * シャッターイベント
 */
- (IBAction)btnShutter:(id)sender {
    
    [imageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL){
            return;
        }
        
        //画像データ取得
        NSData *jpgImageData = [AVCaptureStillImageOutput  jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *jpgImage = [[UIImage alloc] initWithData:jpgImageData];
        
        //画像向き変更
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(jpgImage.size.width, jpgImage.size.height), YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI/180);
        [jpgImage drawInRect:CGRectMake(0, 0, jpgImage.size.width, jpgImage.size.height)];
        UIImage *baseImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //UIImage変換
        NSData *imageData = UIImagePNGRepresentation(baseImage);
        
        if (!ContinueFlg){
            //一時保存
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:imageData forKey:@"TEMP_IMAGE"];
        
            //画面遷移
            AnalysisView *analysisView = [self.storyboard instantiateViewControllerWithIdentifier:@"AnalysisView"];
            analysisView.baseImage = [UIImage imageWithData:[defaults objectForKey:@"TEMP_IMAGE"]];
            [self presentViewController:analysisView animated:NO completion:nil];

        }else{
            //ギャラリーへ保存
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData],
                                           self, @selector(finishSave:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
}


/*
 * ギャラリー選択
 */
- (IBAction)btnGallary:(id)sender {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        [ipc setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        [ipc setDelegate:self];
        [ipc setAllowsEditing:YES];

        [self presentViewController:ipc  animated:NO completion: nil];
    }
}


/*
 * 画面遷移時
 */
- (void)viewWillDisappear:(BOOL)animated{
    [session stopRunning];
    for (AVCaptureOutput *output in session.outputs) {
        [session removeOutput:output];
    }
    for (AVCaptureInput *input in session.inputs) {
        [session removeInput:input];
    }
    imageOutput = nil;
    deviceInput = nil;
    session = nil;
    previewView = nil;
    [previewView removeFromSuperview];
}


/*
 * 遷移元へ戻る
 */
- (IBAction)btnReturn:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}


/*
 * 連続撮影
 */
- (IBAction)btnContinue:(id)sender {
    if (ContinueFlg){
        [self.btnContinue setImage:[UIImage imageNamed:@"btnContinueOff"] forState:UIControlStateNormal];
        ContinueFlg = NO;
    }else{
        [self.btnContinue setImage:[UIImage imageNamed:@"btnContinueOn"] forState:UIControlStateNormal];
        ContinueFlg = YES;
    }
}


/*
 * ギャラリーから画像取得後
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:NO completion:NULL];
    AnalysisView *analysisView = [self.storyboard instantiateViewControllerWithIdentifier:@"AnalysisView"];
    analysisView.baseImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    [self presentViewController:analysisView animated:NO completion:nil];
}


/*
 * 画像保存処理終了時
 */
- (void) finishSave:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo{
    //画像の保存判定
    if (error){
        NSLog(@"Save Error");
    }else{
        //画像解析画面へ格納
        NSLog(@"Save Success");
    }
}


- (void)setPoint:(CGPoint)p
{
    CGSize viewSize = self.view.bounds.size;
    CGPoint pointOfInterest = CGPointMake(p.y / viewSize.height,
                                          1.0 - p.x / viewSize.width);
    
    AVCaptureDevice* videoCaptureDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError* error = nil;
    if ([videoCaptureDevice lockForConfiguration:&error]) {
        
        if ([videoCaptureDevice isFocusPointOfInterestSupported] &&
            [videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            videoCaptureDevice.focusPointOfInterest = pointOfInterest;
            videoCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        }

        [videoCaptureDevice unlockForConfiguration];
    } else {
        NSLog(@"%s|[ERROR] %@", __PRETTY_FUNCTION__, error);
    }
    
}


- (void)didTapGesture:(UITapGestureRecognizer*)tgr
{
    CGPoint p = [tgr locationInView:tgr.view];
    self.indicatorLayer.frame = CGRectMake(p.x - INDICATOR_RECT_SIZE/2.0,
                                           p.y - INDICATOR_RECT_SIZE/2.0,
                                           INDICATOR_RECT_SIZE,
                                           INDICATOR_RECT_SIZE);
    [self setPoint:p];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
