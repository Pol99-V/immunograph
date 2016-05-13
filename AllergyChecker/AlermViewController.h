//
//  AlermViewController.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/25.
//  Copyright © 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlermViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIPickerView *pickerMin;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerSec;
@property (strong, nonatomic) IBOutlet UIButton *btnStart;
- (IBAction)btnStart:(id)sender;
- (IBAction)btnReset:(id)sender;

@end
