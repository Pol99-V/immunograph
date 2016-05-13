//
//  AnalysisView.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultViewController.h"

@protocol AnalysisDelegate;
@interface AnalysisView : UIViewController
{
    UIImageView *canvas;
    CGPoint canvasTouch;
}

@property (strong, nonatomic) IBOutlet UIView *resultView;

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;
@property (strong, nonatomic) IBOutlet UILabel *lblLuminance;
@property (weak, nonatomic) IBOutlet UIButton *btnReCamera;

- (IBAction)btnReCamera:(id)sender;
- (IBAction)btnOK:(id)sender;
- (void) initLabel;
- (IBAction)btnReturn:(id)sender;
- (IBAction)btnClear:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblExplain;

@property (strong, nonatomic) IBOutlet UILabel *lbl1;
@property (strong, nonatomic) IBOutlet UILabel *lbl1_1;
@property (strong, nonatomic) IBOutlet UILabel *lbl1_2;

@property (strong, nonatomic) IBOutlet UILabel *lbl2;
@property (strong, nonatomic) IBOutlet UILabel *lbl2_1;
@property (strong, nonatomic) IBOutlet UILabel *lbl2_2;

@property (strong, nonatomic) IBOutlet UILabel *lbl3;
@property (strong, nonatomic) IBOutlet UILabel *lbl3_1;
@property (strong, nonatomic) IBOutlet UILabel *lbl3_2;

@property UIImage *baseImage;
@property int baseOrientation;
@property (strong, nonatomic) IBOutlet UIView *viewRGB;
@property NSString *updateID;

@property (nonatomic, assign) id<AnalysisDelegate> delegate;

@end


@protocol AnalysisDelegate <NSObject>

-(void)setLuminanceLabel:(NSArray *) luminanceList;

@end