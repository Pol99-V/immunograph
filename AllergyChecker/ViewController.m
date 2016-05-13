//
//  ViewController.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewContoroller.h"

@interface ViewController ()

@end


@implementation ViewController


//使い方用
CGFloat scrollWidth;
CGFloat scrollHeight;
int allPageIndex = 9;

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)viewDidAppear:(BOOL)animated{
    scrollWidth = self.scrollView.frame.size.width;
    scrollHeight = self.scrollView.frame.size.height;

    //通知設定の有無
    if([[UIApplication sharedApplication] scheduledLocalNotifications].count == 0){
        self.btnInfo.hidden = YES;
    }else{
        self.btnInfo.hidden = NO;
    }
    
    //説明画像ビューの作成
    for (int i = 1; i <= allPageIndex; i++){
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"img%d.png", i]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        
        CGRect rect = imgView.frame;
        rect.size.width = scrollWidth;
        rect.size.height = scrollHeight;
        imgView.frame = rect;
        imgView.tag = i;
        [self.scrollView addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleToFill;
    }
    
    //説明画像ビューのスクロール設定
    UIImageView *view = nil;
    NSArray *subViews = [self.scrollView subviews];
    
    CGFloat frmPoint = 0;
    for (view in subViews){
        if ([view isKindOfClass:[UIImageView class]] && view.tag > 0) {
            CGRect frame = view.frame;
            frame.origin = CGPointMake(frmPoint, 0);
            view.frame = frame;
            
            frmPoint += scrollWidth;
        }
    }
    [self.scrollView setContentSize:CGSizeMake(allPageIndex * scrollWidth, scrollHeight)];
    
    //スクロールバー非表示
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
}



/*
 * 説明画像スクロール時
 */
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    if (fmod(self.scrollView.contentOffset.x, pageWidth) == 0.0){
        self.pageControll.currentPage = self.scrollView.contentOffset.x / pageWidth;
    }
}


/*
 * ページコントロールタップ時
 */
- (IBAction)pageControll:(id)sender {
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControll.currentPage;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}


/*
 * 検査器撮影
 */
- (IBAction)btnCamera:(id)sender {
    if([[UIApplication sharedApplication] scheduledLocalNotifications].count != 0){
       
        NSString *msg = @"アラームが設定されていますが、検査器の撮影を行いますか？";
        if (NSClassFromString(@"UIAlertController")) {
            //iOS8以降
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
            [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self transitionCamera];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:nil]];
        
            [self presentViewController:alertController animated:YES completion:nil];
        
        }else{
            //iOS7以前
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:msg delegate:self
                                                  cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい",nil];
            [alert show];
        }
    }else{
        [self transitionCamera];
    }
}


/*
 * アラートボタンタップ時
 */
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //OKボタンタップ時
    if(buttonIndex == 1){
        [self transitionCamera];
    }
}


/*
 * 検査器撮影へ遷移
 */
- (void)transitionCamera{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    CameraViewContoroller *cameraView = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraView"];
    [self presentViewController:cameraView animated:NO completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
