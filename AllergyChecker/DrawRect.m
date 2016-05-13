//
//  DrawRect.m
//  AllergyChecker
//
//  Created by 磯浩一郎 on 2016/05/06.
//  Copyright © 2016年 prage. All rights reserved.
//

#import "DrawRect.h"

@implementation DrawRect


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // UIBezierPath のインスタンス生成
/*    UIBezierPath *line = [UIBezierPath bezierPath];
    
    // 起点
    [line moveToPoint:CGPointMake(50,50)];
    
    // 帰着点
    [line addLineToPoint:CGPointMake(220,350)];
    
    // 色の設定
    [[UIColor redColor] setStroke];
    // ライン幅
    line.lineWidth = 2;
    // 描画
    [line stroke];
*/
    // 矩形 -------------------------------------
    UIBezierPath *rectangle =
    [UIBezierPath bezierPathWithRect:CGRectMake(200,70,100,80)];
    [[UIColor blueColor] setStroke];
    rectangle.lineWidth = 8;
    [rectangle stroke];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.clearColor; //背景を透明に
    }
    return self;
}


@end
