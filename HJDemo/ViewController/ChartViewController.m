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
}
@end

@implementation ChartViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    stockCode = @"600123";
    
    if (![self getCacheData]) {
        [self getURLData];
    }
}

- (BOOL)getCacheData
{
    NSArray *stockArr = [self readFromPlistByName:[NSString stringWithFormat:@"%@.plist",stockCode]];
    
    if (CHECK_VALID_ARRAY(stockArr) && [stockArr count]>0) {
        HJChartView *chartView = [[HJChartView alloc]initWithData:stockArr];
        chartView.frame = CGRectMake(15, 20, kScreenWidth - 30, kScreenWidth - 30);
        [self.view addSubview:chartView];
        
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

@end
