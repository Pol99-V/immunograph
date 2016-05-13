//
//  ViewController.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet UIView *footerView;
- (IBAction)pageControll:(id)sender;
- (IBAction)btnCamera:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *imgView;

@end

