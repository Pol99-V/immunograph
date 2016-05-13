//
//  HistoryViewController.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/15.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController<UITableViewDelegate>{
    UITableView *tableView_;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;

- (IBAction)btnAllClear:(id)sender;

@end


