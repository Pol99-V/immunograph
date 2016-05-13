//
//  CustomCell.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/15.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblResult;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblComment;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;

@end
