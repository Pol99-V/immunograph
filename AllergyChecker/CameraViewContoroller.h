//
//  CameraViewContoroller.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewContoroller : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)btnShutter:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIButton *btnContinue;
@property (strong, nonatomic) IBOutlet UIView *viewGuide;
- (IBAction)btnGallary:(id)sender;
- (IBAction)btnReturn:(id)sender;
- (IBAction)btnContinue:(id)sender;

//focus point
- (void)setPoint:(CGPoint)p;

@property (nonatomic, strong) CALayer* indicatorLayer;
@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput* imageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@end

