//
//  ChartViewController.m
//  HJDemo
//
//  Created by jixuhui on 16/1/12.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "ChartViewController.h"

#import "HJCandleChartModel.h"
#import "HJChartView.h"
#import "HJChartViewModel.h"

#import "HJArchitecture.h"

@interface ChartViewController()
{
    NSString *_stockCode;
    NSString *_candleType;
    NSString *_candleInfoType;
    CGFloat _statusBarTop;
    float _candleDateBtnHeight;
    
    NSMutableArray *_stockInfo;
    
    NSMutableArray *_candleDateBtnArr;
    NSMutableArray *_candleInfoBtnArr;
}
@property (nonatomic,strong)HJChartView *chartView;
@end

@implementation ChartViewController

- (instancetype)initWithStockInfo:(NSArray *)arr
{
    self = [self init];
    if (self) {
        _stockCode = [arr firstObject];
        _stockInfo = [NSMutableArray arrayWithArray:arr];
        
        _candleDateBtnArr = [[NSMutableArray alloc] initWithCapacity:3];
        _candleInfoBtnArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}
 
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _candleDateBtnHeight = 25;
    
    _candleType = @"d";
    
    self.chartView = [[HJChartView alloc]initWithViewModel:[[HJChartViewModel alloc] init]];
    [self.view addSubview:self.chartView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self resetContentView];
    
    _candleType = @"d";
    self.chartView.viewModel.modelType = CHART_MODEL_TYPE_DAY;
    [self doDatePublicAction];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect r = self.view.superview.frame;
    
    _statusBarTop = r.origin.y;
    
    if(_statusBarTop != 0.0f){
        self.view.superview.frame = self.view.window.bounds;
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    if(_statusBarTop != 0.0f){
        CGRect r = self.view.superview.frame;
        r.origin.y = _statusBarTop;
        r.size.height -= _statusBarTop;
        self.view.superview.frame = r;
    }
}

-(void) resetContentView
{
    BOOL Transformed = [self.chartView transformed];
    if (!Transformed) {
        if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
            [self.chartView setTransform:CGAffineTransformMakeRotation(- M_PI_2)];
            [self.chartView setTransformed:YES];
        }
        else{
            [self.chartView setTransform:CGAffineTransformMakeRotation( M_PI_2)];
            [self.chartView setTransformed:YES];
        }
        
        CGSize size = self.view.bounds.size;
        
        [self.chartView setFrame:CGRectMake(0, 0, size.width, size.height)];
        
        [self addCandleDateChangeButtons];
        
        [self addCandleLineScrollView];
        
        [self addBackButton];
    }
}

- (BOOL)getCacheData
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init]; [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    NSArray *stockArr = [self readFromPlistByName:[NSString stringWithFormat:@"%@_%@_%@.plist",_stockCode,_candleType,date]];
    
    if (CHECK_VALID_ARRAY(stockArr) && [stockArr count]>0) {
        [self.chartView.viewModel setModelsArray:stockArr];
        [self.chartView.viewModel setStockInfo:_stockInfo];
        [self.chartView renderMe];
        return YES;
    }else {
        return NO;
    }
}

-(void)getURLData
{
    HJURLTask *task = [[HJURLTask alloc]init];
    task.urlString = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&g=%@",_stockCode,_candleType];
    task.responseDataType = @"Serial";
    
    [[HJURLService shareService] handleSessionTask:task success:^(NSURLSessionDataTask *task, id responseObject) {
        [self stopLoading];
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self generateData:result];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@,%@",task,error.description);
        [self stopLoading];
        [self showErrorWithStr:error.localizedDescription];
    }];
}

-(void)generateData:(NSString *)responseString
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init]; [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    NSArray *lines = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    [self writeToPlistWithData:lines Name:[NSString stringWithFormat:@"%@_%@_%@.plist",_stockCode,_candleType,date]];
    
    [self getCacheData];
}

-(void)writeToPlistWithData:(NSArray *)stockArr Name:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    [stockArr writeToFile:filePath atomically:YES];
}

- (NSArray *)readFromPlistByName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:name];
    
    NSLog(@"stock data cache path...%@",filePath);
    
    NSArray *lines = [[NSMutableArray alloc]initWithContentsOfFile:filePath];
    return [self transformToModel:lines];
}

- (void)deleteOldStockFileByNewFileNamePrefix:(NSString *)prefix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:path]){
        //取得一个目录下得所有文件名
        NSArray *files = [fm subpathsAtPath:path];
        
        for (NSString *fileName in files) {
            
            NSDateFormatter * formatter = [[NSDateFormatter alloc ] init]; [formatter setDateFormat:@"YYYY-MM-dd"];
            NSString *date = [formatter stringFromDate:[NSDate date]];
            
            if ([fileName hasPrefix:prefix] && ![fileName isEqualToString:[NSString stringWithFormat:@"%@_%@",prefix,date]]) {
                
                NSString *filePath = [path stringByAppendingPathComponent:fileName];
                NSError *error = nil;
                [fm removeItemAtPath:filePath error:&error];
                break;
                
            }
        }
    }
}

- (NSArray *)transformToModel:(NSArray *)lines
{
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];//保存日期值
    NSInteger idx;
    for (idx = lines.count-1; idx > 0; idx--) {
        NSString *line = lines[idx];
        if([line isEqualToString:@""]){
            continue;
        }
        
        @autoreleasepool {
            NSArray   *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            [category addObject:arr[0]];
            
            HJCandleChartModel *model = [[HJCandleChartModel alloc]init];
            model.date = arr[0];
            model.openPrice = [arr[1] floatValue];
            model.highPrice = [arr[2] floatValue];
            model.lowPrice = [arr[3] floatValue];
            model.closePrice = [arr[4] floatValue];
            model.volume = [arr[5] intValue];
            model.adjClosePrice = [arr[6] floatValue];
            [data addObject:model];
        }
    }
    
    return data;
}

- (void)addBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"fullback.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setFrame:CGRectMake(0, 10, 90/2, 85/2)];
    [self.chartView addSubview:backBtn];
}

- (void)addCandleDateChangeButtons
{
    float leftPoint = 50.0f;
    float width = (CGRectGetWidth(self.chartView.bounds) - leftPoint*2)/3;
    
    HJButton *dayBtn = [self createHJButtonWithActionName:@"DAY"];
    [dayBtn setFrame:CGRectMake(leftPoint, CGRectGetHeight(self.chartView.bounds)-30, width, _candleDateBtnHeight)];
    dayBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    
    leftPoint += width;
    
    HJButton *weekBtn = [self createHJButtonWithActionName:@"WEEK"];
    [weekBtn setFrame:CGRectMake(leftPoint, CGRectGetHeight(self.chartView.bounds)-30, width, _candleDateBtnHeight)];
    weekBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    
    leftPoint += width;
    
    HJButton *monthBtn = [self createHJButtonWithActionName:@"MONTH" ];
    [monthBtn setFrame:CGRectMake(leftPoint, CGRectGetHeight(self.chartView.bounds)-30, width, _candleDateBtnHeight)];
    monthBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    
    [self.chartView addSubview:dayBtn];
    [self.chartView addSubview:weekBtn];
    [self.chartView addSubview:monthBtn];
    
    [_candleDateBtnArr addObject:dayBtn];
    [_candleDateBtnArr addObject:weekBtn];
    [_candleDateBtnArr addObject:monthBtn];
}

- (void)addCandleLineScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.chartView.bounds)-60, 90, 50, CGRectGetHeight(self.chartView.bounds)-130)];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.chartView addSubview:scrollView];
    
    HJButton *volumeBtn = [self createHJButtonWithActionName:@"VOLUME"];
    [volumeBtn setFrame:CGRectMake(0, 0, 50, 30)];
    [scrollView addSubview:volumeBtn];
    [_candleInfoBtnArr addObject:volumeBtn];
    [self doAction:volumeBtn];
    
    HJButton *kdjBtn = [self createHJButtonWithActionName:@"KDJ"];
    [kdjBtn setFrame:CGRectMake(0, 50, 50, 30)];
    [scrollView addSubview:kdjBtn];
    [_candleInfoBtnArr addObject:kdjBtn];
    
    HJButton *rsiBtn = [self createHJButtonWithActionName:@"RSI"];
    [rsiBtn setFrame:CGRectMake(0, 100, 50, 30)];
    [scrollView addSubview:rsiBtn];
    [_candleInfoBtnArr addObject:rsiBtn];
}

- (HJButton *)createHJButtonWithActionName:(NSString *)actionName
{
    HJButton *btn = [HJButton buttonWithType:UIButtonTypeCustom];
    btn.actionName = actionName;
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:actionName forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:10];
    [btn addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

#pragma mark - actions

- (void)doAction:(HJButton *)sender
{
    _candleInfoType = sender.actionName;
    
    if ([sender.actionName isEqualToString:@"VOLUME"]) {
        self.chartView.viewModel.infoType = CHART_INFO_TYPE_VOLUME;
        [self doInfoPublicAction];
    }else if ([sender.actionName isEqualToString:@"KDJ"]) {
        self.chartView.viewModel.infoType = CHART_INFO_TYPE_KDJ;
        [self doInfoPublicAction];
    }else if ([sender.actionName isEqualToString:@"RSI"]) {
        self.chartView.viewModel.infoType = CHART_INFO_TYPE_RSI;
        [self doInfoPublicAction];
    }else if ([sender.actionName isEqualToString:@"DAY"]) {
        _candleType = @"d";
        self.chartView.viewModel.modelType = CHART_MODEL_TYPE_DAY;
        [self doDatePublicAction];
    }else if ([sender.actionName isEqualToString:@"WEEK"]) {
        _candleType = @"w";
        self.chartView.viewModel.modelType = CHART_MODEL_TYPE_WEEK;
        [self doDatePublicAction];
    }else if ([sender.actionName isEqualToString:@"MONTH"]) {
        _candleType = @"m";
        self.chartView.viewModel.modelType = CHART_MODEL_TYPE_MONTH;
        [self doDatePublicAction];
    }
}

- (void)doDatePublicAction
{
    for (UIButton *btn in _candleDateBtnArr) {
        if ([[btn.titleLabel.text lowercaseString] hasPrefix:_candleType]) {
            btn.selected = YES;
        }else {
            btn.selected = NO;
        }
    }
    
    [self.chartView resetMe];
    
    [self deleteOldStockFileByNewFileNamePrefix:[NSString stringWithFormat:@"%@_%@",_stockCode,_candleType]];
    
    if (![self getCacheData]) {
        [self startLoading];
        [self getURLData];
    }
}

- (void)doInfoPublicAction
{
    for (HJButton *btn in _candleInfoBtnArr) {
        if ([btn.actionName isEqualToString:_candleInfoType]) {
            btn.selected = YES;
        }else {
            btn.selected = NO;
        }
    }
    
    [self.chartView setNeedsDisplay];
}

- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startLoading
{
    //因为是view旋转了，所以添加背景视图是在原来的坐标系
    CGRect rect = self.view.bounds;
    rect.origin.y = 50;
    rect.size.height -= 50;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:rect];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.tag = 101;
    [self.view addSubview:backgroundView];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.tag = 102;
    indicatorView.center = self.view.center;
    [indicatorView startAnimating];
    [self.view addSubview:indicatorView];
}

- (void)stopLoading
{
    UIView *bgView = [self.view viewWithTag:101];
    [bgView removeFromSuperview];
    
    UIActivityIndicatorView *indicatorView = [self.view viewWithTag:102];
    [indicatorView stopAnimating];
    [indicatorView removeFromSuperview];
}

- (void)showErrorWithStr:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
