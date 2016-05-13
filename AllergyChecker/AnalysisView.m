//
//  AnalysisView.m
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/08.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import "AnalysisView.h"
#import "ResultViewController.h"
#import "CameraViewContoroller.h"
#import "DrawRect.h"

@interface AnalysisView ()
//@property UIImageView *imageView;
@property size_t bytesPerPixel;
@property size_t bytePerRow;
@property UInt8 *buffer;
@end

@implementation AnalysisView
@synthesize baseImage;
@synthesize baseOrientation;
@synthesize updateID;

//解析用変数
int imageWidth, imageHeight;
float image_x, image_y, rate;
CGImageRef cgImage;

//範囲指定開始位置
CGPoint sPoint;
//範囲指定終了位置
CGPoint ePoint;
//ポイント
CGPoint maxPoint;
CGPoint minPoint;
//輝度用変数
float lumi_max, lumi_min;
//選択範囲移動用
CGPoint startPt, startCanvasPos;



//mode
int mode; // 0:四角描画前    1:四角描画後

//選択範囲畳みかけ用
int i,j;


//プレビュー用
int previewWidth = 130;
int previewHeight = 145;

int count;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //ビューの作成
//    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:self.imageView];
//    [self.view sendSubviewToBack:self.imageView];
//    
//    //ImageViewフレーム変更
//    self.imageView.translatesAutoresizingMaskIntoConstraints = YES;
//    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//
//    //解析用画像
//    UIImage *analysisImage = [UIImage imageWithCGImage:baseImage.CGImage scale:baseImage.scale orientation:0];
//    self.imageView.image = analysisImage;
//    
//    //サイズ測定
//    imageWidth = analysisImage.size.width;
//    imageHeight = analysisImage.size.height;

    self.imageView.image = baseImage;
    self.imageView.frame = CGRectMake((self.view.bounds.size.width/2) - (baseImage.size.width/2),
                                      (self.view.bounds.size.height/2) - (baseImage.size.height/2),
                                      baseImage.size.width,
                                      baseImage.size.height);
    [self.view sendSubviewToBack:self.imageView];
    
    
    imageWidth = baseImage.size.width;
    imageHeight = baseImage.size.height;
    
    int viewWidth = self.view.bounds.size.width;
    int viewHeight = self.view.bounds.size.height;
 
    NSLog(@"%d,%d",viewWidth,viewHeight);
    NSLog(@"%d,%d",imageWidth,imageHeight);
    
    
    //撮影画像を再背面に表示
    if(imageWidth > viewWidth || imageHeight > viewHeight){
        //画像サイズが大きい場合は画面サイズに合わせる
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //比率計算
        if(imageWidth/viewWidth > imageHeight/viewHeight){
            rate = (float)viewWidth/(float)imageWidth;
        }else{
            rate = (float)viewHeight/(float)imageHeight;
        }
    }else{
        //画像サイズが小さい場合はそのまま表示
        self.imageView.contentMode = UIViewContentModeCenter;
        rate = 1.0;
    }
    
    //画像表示開始位置計算
    image_x = (self.view.bounds.size.width - (imageWidth * rate)) / 2;
    image_y = (self.view.bounds.size.height - (imageHeight * rate)) / 2;
    NSLog(@"bound_w:%f,bound_h:%f", self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"image_w:%f,image_h:%f", baseImage.size.width, baseImage.size.height);
    NSLog(@"image_x:%f,image_y:%f", image_x, image_y);
    
    //画像詳細を取得
    cgImage = self.baseImage.CGImage;
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    self.bytePerRow = CGImageGetBytesPerRow(cgImage);
    
    //画像からビットマップデータ取得
    CFMutableDataRef dataRef = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(provider));
    self.buffer = (UInt8*)CFDataGetMutableBytePtr(dataRef);
    
    
    
    //キャンバス用のUIImageViewを作成
    canvas = [[UIImageView alloc]init];
    canvas.frame = self.view.bounds;
    canvas.image = [self getImageNew];
    canvas.layer.borderWidth = 4;
//    canvas.layer.borderColor = [[UIColor redColor]CGColor];
    [self.view addSubview:canvas];

    mode = 0;
}


/*
 * ページ読み込み時
 */
- (void)viewDidAppear:(BOOL)animated{
    count = 1;
    [self initLabel];
    self.preview.hidden = YES;
}


/*
 * タップイベント(開始)
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.view];
//    
//    [self createPreview:point];

    
    
    //対象のキャンバスを選択
    UITouch *touch = [touches anyObject];
//    canvasTouch  = [touch locationInView:canvas];
    
    sPoint = [touch locationInView:self.view];

}


/*
 * タップイベント(移動)
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.view];
//    
//    [self createPreview:point];
    

    if(mode==0){
        //描画処理
        [self touch2draw:touches];
    }else if(mode==1){
//        startPt = [touch locationInView:self];
        
    }else{
        
    }
}


/*
 * プレビュー作成
 */
- (void)createPreview:(CGPoint) point{
    //プレビュー画像作成
    int basePointX = (int)(point.x - image_x) / rate;
    int basePointY = (int)(point.y - image_y) / rate;
    CGRect trimArea = CGRectMake(basePointX - (previewWidth / 2),
                                 basePointY - (previewHeight / 2),
                                 previewWidth, previewHeight);
    CGImageRef trimImageRef = CGImageCreateWithImageInRect(cgImage, trimArea);
    
    //プレビュー表示
    self.preview.hidden = NO;
    self.previewImage.image = [UIImage imageWithCGImage:trimImageRef];
    self.previewImage.contentMode = UIViewContentModeCenter;
    
    //NSLog(@"point_x:%f,point_y:%f", point.x, point.y);
    //NSLog(@"convert_x:%f,convert_y:%f", point.x-image_x, point.y-image_y);
    
    if(point.x < image_x || point.y < image_y ||
       point.x > image_x+imageWidth/rate || point.y > image_y+imageHeight/rate){
        return;
    }
    
    //取得対象ビクセル
    UInt8 *target = self.buffer + (int)((point.y-image_y)/rate) * self.bytePerRow + (int)((point.x-image_x)/rate) * 4;
    
    //RGBA取得
    UInt8 r, g, b, a, l;
    r = *(target + 0);  //赤
    g = *(target + 1);  //緑
    b = *(target + 2);  //青
    a = *(target + 3);  //アルファ値
    l = (0.298912 * r + 0.586611 * g + 0.114478 * b);   //輝度
    //NSLog(@"%d, %d, %d, %d, %d" ,r,g,b,a,l);
    
    //輝度を文字列に変換
    //self.lblLuminance.text = [NSString stringWithFormat:@"X:%d,Y:%d,R:%d,G:%d,B:%d,L:%d",(int)point.x,(int)point.y,r,g,b,l];
    self.lblLuminance.text = [NSString stringWithFormat:@"%d",l];
    self.viewRGB.backgroundColor = [UIColor colorWithRed:(float)r/255 green:(float)g/255 blue:(float)b/255 alpha:1];
}


/*
 * タップイベント(終了)
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.preview.hidden = YES;

    UITouch *touch = [touches anyObject];
    float lux,luy,rdx,rdy;

    ePoint = [touch locationInView:self.view];

    if(sPoint.x < ePoint.x){
        lux = sPoint.x;
        rdx = ePoint.x;
    }else{
        lux = ePoint.x;
        rdx = sPoint.x;
    }

    if(sPoint.y < ePoint.y){
        luy = sPoint.y;
        rdy = ePoint.y;
    }else{
        luy = ePoint.y;
        rdy = sPoint.y;
    }
    sPoint.x = lux;
    sPoint.y = luy;
    ePoint.x = rdx;
    ePoint.y = rdy;
    
    int tWidth = abs((int)(ePoint.x - sPoint.x));
    int tHeight = abs((int)(ePoint.y - sPoint.y));

//    int tWidth = ePoint.x - sPoint.x;
//    int tHeight = ePoint.y - sPoint.y;

    if(mode==0){
        mode=1;
        
        lumi_max = 0.0, lumi_min = 1.0;
        CGPoint tPoint;
        int maxx=0,maxy=0,minx=0,miny=0;
        
        for(i=sPoint.x;i<=sPoint.x+tWidth;i++){
            for(j=sPoint.y;j<=sPoint.y+tHeight;j++){
                float tmp;
                tPoint.x = i;
                tPoint.y = j;
                tmp = [self calLuminance:tPoint];
                if(tmp<=lumi_min){
                    lumi_min = tmp;
                    minx = i;//(int)((i-image_x)/rate);
                    miny = j;//(int)((j-image_y)/rate);
                }
                if(tmp>=lumi_max){
                    lumi_max = tmp;
                    maxx = i;//(int)((i-image_x)/rate);
                    maxy = j;//(int)((j-image_y)/rate);
                }
            }
        }
        
        maxPoint.x = maxx;
        maxPoint.y = maxy;
        [self point2draw:0];
        
        minPoint.x = minx;
        minPoint.y = miny;
        [self point2draw:1];
        
        NSLog(@"sPointx:%d sPointy:%d" ,(int)sPoint.x,(int)sPoint.y);
        NSLog(@"maxx:%d maxy:%d" ,(int)maxx,(int)maxy);
        NSLog(@"minx:%d miny:%d" ,(int)minx,(int)miny);
        NSLog(@"maxPointx:%d maxPointy:%d" ,(int)maxPoint.x,(int)maxPoint.y);
        NSLog(@"minPointx:%d minPointy:%d" ,(int)minPoint.x,(int)minPoint.y);
        NSLog(@"rate:%f" ,rate);

        NSLog(@"lumi_max:%f lumi_min:%f" ,lumi_max,lumi_min);

    }else if (mode==1){
        
    }else{
        
    }
    
    self.lblExplain.text = @"";
    self.btnOK.hidden = NO; //OKボタンを表示
}

/*
 * 輝度計算
 */
- (float)calLuminance:(CGPoint) point{
    //プレビュー画像作成
    int basePointX = (int)((point.x-image_x)/rate);
    int basePointY = (int)((point.y-image_y)/rate);
//    CGRect trimArea = CGRectMake(basePointX - (previewWidth / 2),
//                                 basePointY - (previewHeight / 2),
//                                 previewWidth, previewHeight);
//    CGImageRef trimImageRef = CGImageCreateWithImageInRect(cgImage, trimArea);
//    
//    //プレビュー表示h
//    self.preview.hidden = NO;
//    self.previewImage.image = [UIImage imageWithCGImage:trimImageRef];
//    self.previewImage.contentMode = UIViewContentModeCenter;
    
    //NSLog(@"point_x:%f,point_y:%f", point.x, point.y);
    //NSLog(@"convert_x:%f,convert_y:%f", point.x-image_x, point.y-image_y);
    
    if(point.x < image_x || point.y < image_y ||
       point.x > image_x+imageWidth/rate || point.y > image_y+imageHeight/rate){
        return 0.0f;
    }
    
    //取得対象ビクセル
    UInt8 *target = self.buffer + basePointY * self.bytePerRow + basePointX * 4;
//    UInt8 *target = self.buffer + (int)(point.y/rate) * self.bytePerRow + (int)(point.x/rate) * 4;
    
    //RGBA取得
    UInt8 r, g, b, a;
    float l;
    r = *(target + 0);  //赤
    g = *(target + 1);  //緑
    b = *(target + 2);  //青
    a = *(target + 3);  //アルファ値
    l = (0.298912 * r + 0.586611 * g + 0.114478 * b);   //輝度
    NSLog(@"%d, %d, %d, %d, %f" ,r,g,b,a,l);
    

    //輝度を文字列に変換
    self.lblLuminance.text = [NSString stringWithFormat:@"X:%d,Y:%d,R:%d,G:%d,B:%d,L:%f",(int)point.x,(int)point.y,r,g,b,l];
    self.lblLuminance.text = [NSString stringWithFormat:@"%f",l];
    self.viewRGB.backgroundColor = [UIColor colorWithRed:(float)r/255 green:(float)g/255 blue:(float)b/255 alpha:1];

    return l/255.0;
    
}



/*
 * 再撮影ボタンタップ時
 */
- (IBAction)btnReCamera:(id)sender {
    CameraViewContoroller *cameraView = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraView"];
    [self presentViewController:cameraView animated:NO completion:nil];
}


/*
 * OKボタンタップ時
 */
- (IBAction)btnOK:(id)sender {
    //遷移処理
    ResultViewController *resultView = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultView"];
    
//    NSArray *luminanceList = @[self.lbl1_1.text, self.lbl2_1.text, self.lbl3_1.text,
//                               self.lbl1_2.text, self.lbl2_2.text, self.lbl3_2.text];

    
    
    NSString *st1,*st2;
    st1 = [NSString stringWithFormat:@"%.4f",lumi_max];
    st2 = [NSString stringWithFormat:@"%.4f",lumi_min];
    NSArray *luminanceList = @[st1,st2];//,@"",@"",@"",@""];

    
    
    
    //画面遷移
    if (updateID != nil){
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.delegate setLuminanceLabel:luminanceList];
    }else{
        [self presentViewController:resultView animated:NO completion:nil];
        resultView.registImage = baseImage;
        [resultView setLuminanceLabel:luminanceList];
    }
}


/*
 * ラベル設定（枠線）
 */
- (void) initLabel{
    //セル設定(9)
    for (int i = 1; i <= 9; i++){
        UILabel *lbl = (UILabel *)[self.view viewWithTag:i];
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 0.5;
    }
    [self setLabel];
}


/*
 * 戻る
 */
- (IBAction)btnReturn:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}


/*
 * クリアボタンタップ時
 */
- (IBAction)btnClear:(id)sender {
    count = 1;
    [self setLabel];
    self.lblExplain.text = @"白紙部分を選択して下さい。";
    
    if(mode==1){
        mode=0;
    }
}


/*
 * 計測値の初期化
 */
- (void) setLabel{
    //OKボタン非表示
    self.btnOK.hidden = YES;
    if(updateID == nil){
        self.btnReCamera.hidden = YES;
    }
    
    //値のセット
    self.lbl1_1.text = @"--";
    self.lbl1_2.text = @"--";
//    self.lbl2_1.text = @"--";
//    self.lbl2_2.text = @"--";
//    self.lbl3_1.text = @"--";
//    self.lbl3_2.text = @"--";
}

//空白画像の作成
-(UIImage *)getImageNew{
    UIImage *img = [[UIImage alloc]init];
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//描き込み
-(void)touch2draw:(NSSet *)touches {
    
    //初期設定
    float scale = 1.0f;
    float penSize = 1.0f;
    
    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:canvas];
    
    // 描画領域をcanvasの大きさで生成
    UIGraphicsBeginImageContext(canvas.image.size);
    
    //キャンバス座標
    float x = 0;
    float y = 0;
    float w = canvas.image.size.width;
    float h = canvas.image.size.height;
    
//    // canvasにセットされている画像（UIImage）を描画
//    [canvas.image drawInRect:CGRectMake(x,y,w,h)];
    
//    // 線の角を丸くする
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    // 線の太さを指定
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), penSize);
    
    // 線の色を指定（RGB）
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    
//    // 線の描画開始座標をセット
//    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), canvasTouch.x*scale, canvasTouch.y*scale);
//    
//    // 線の描画終了座標をセット
//    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x*scale, currentPoint.y*scale);
//    

    // 四角を描画
    CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(sPoint.x, sPoint.y,
                                                               currentPoint.x - sPoint.x, currentPoint.y - sPoint.y));

    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(UIGraphicsGetCurrentContext());

    
    
    // 描画領域を画像（UIImage）としてcanvasにセット
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画領域のクリア
    UIGraphicsEndImageContext();
    
//    // 現在のタッチ座標を次の開始座標にセット
//    canvasTouch = currentPoint;
}

//描き込み 輝度の最小、最高値をプロットする
-(void)point2draw:(int)highLow {
    
    //初期設定
    float scale = 1.0f;
    float penSize = 1.0f;

    // 描画領域をcanvasの大きさで生成
    UIGraphicsBeginImageContext(canvas.image.size);
    
    //キャンバス座標
    float x = 0;
    float y = 0;
    float w = canvas.image.size.width;
    float h = canvas.image.size.height;
    
        // canvasにセットされている画像（UIImage）を描画
        [canvas.image drawInRect:CGRectMake(x,y,w,h)];
    
    //    // 線の角を丸くする
    //    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    // 線の太さを指定
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), penSize);
    
    // 線の色を指定（RGB）
    if(highLow==0){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 1.0, 0.0, 1.0);
    }else if(highLow==1){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
    }else{
        
    }
    
    //    // 線の描画開始座標をセット
    //    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), canvasTouch.x*scale, canvasTouch.y*scale);
    //
    //    // 線の描画終了座標をセット
    //    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x*scale, currentPoint.y*scale);
    //
    
    // 四角を描画
    if(highLow==0){
        CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(maxPoint.x, maxPoint.y, 1, 1));
    }else if(highLow==1){
        CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(minPoint.x, minPoint.y, 1, 1));
    }else{
        
    }

    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    
    
    // 描画領域を画像（UIImage）としてcanvasにセット
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画領域のクリア
    UIGraphicsEndImageContext();
    
    //    // 現在のタッチ座標を次の開始座標にセット
    //    canvasTouch = currentPoint;
}

//描き込み
-(void)moveRect:(NSSet *)touches {

    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:canvas];
    
    // 描画領域をcanvasの大きさで生成
    UIGraphicsBeginImageContext(canvas.image.size);
    
    //キャンバス座標
    float x = 0;
    float y = 0;
    float w = canvas.image.size.width;
    float h = canvas.image.size.height;
    
    //canvas.frame.origin.x +=
    
    //    // canvasにセットされている画像（UIImage）を描画
    //    [canvas.image drawInRect:CGRectMake(x,y,w,h)];
    
    //    // 線の角を丸くする
    //    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    // 線の太さを指定
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), penSize);
    
    // 線の色を指定（RGB）
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    
    //    // 線の描画開始座標をセット
    //    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), canvasTouch.x*scale, canvasTouch.y*scale);
    //
    //    // 線の描画終了座標をセット
    //    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x*scale, currentPoint.y*scale);
    //
    
    // 四角を描画
    CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(sPoint.x, sPoint.y,
                                                               currentPoint.x - sPoint.x, currentPoint.y - sPoint.y));
    
    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    
    
    // 描画領域を画像（UIImage）としてcanvasにセット
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画領域のクリア
    UIGraphicsEndImageContext();
    
    //    // 現在のタッチ座標を次の開始座標にセット
    //    canvasTouch = currentPoint;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end









