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

@interface ChartViewController()
{
    NSString *stockCode;
    CGFloat _statusBarTop;
}
@property (nonatomic,strong)HJChartView *chartView;
@end

@implementation ChartViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    stockCode = @"600123";
    
    self.chartView = [[HJChartView alloc]init];
    [self.view addSubview:self.chartView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self resetContentView];
    
    if (![self getCacheData]) {
        [self getURLData];
    }
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
        
        [self addBackButton];
        
        [self.chartView renderMe];
    }
}

- (BOOL)getCacheData
{
    NSArray *stockArr = [self readFromPlistByName:[NSString stringWithFormat:@"%@.plist",stockCode]];
    
    if (CHECK_VALID_ARRAY(stockArr) && [stockArr count]>0) {
        [self.chartView setModelsArray:stockArr];
        [self.chartView renderMe];
        return YES;
    }else {
        return NO;
    }
}

-(void)getURLData
{
    HJURLTask *task = [[HJURLTask alloc]init];
    task.urlString = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@.SS&g=%@",stockCode,@"d"];
    task.responseDataType = @"Serial";
    
    [[HJURLService shareService] handleSessionTask:task success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self generateData:result];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@,%@",task,error);
    }];
}

-(void)generateData:(NSString *)responseString
{
    NSArray *lines = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    [self writeToPlistWithData:lines Name:[NSString stringWithFormat:@"%@.plist",stockCode]];
    
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

- (BOOL)shouldAutorotate{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)addBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"fullback.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setFrame:CGRectMake(10, 10, 90/2, 85/2)];
    [self.chartView addSubview:backBtn];
}

- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
