//
//  ChartViewController.m
//  HJDemo
//
//  Created by jixuhui on 16/1/12.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "ChartViewController.h"

#import "HJCandleChartModel.h"

@implementation ChartViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getData];
}

-(void)getData
{
    HJURLTask *task = [[HJURLTask alloc]init];
    task.requestType = @"get";
    task.urlString = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&g=%@",@"600999.SS",@"d"];
    
    [[HJURLService shareService] handleSessionTask:task success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self generateData:result];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@,%@",task,error);
    }];
}

-(void)generateData:(NSString *)responseString
{
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];//保存日期值
    
    NSArray *lines = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
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
            model.hightPrice = [arr[2] floatValue];
            model.lowPrice = [arr[3] floatValue];
            model.closePrice = [arr[4] floatValue];
            model.volumn = [arr[5] intValue];
            model.adjClosePrice = [arr[6] floatValue];
            [data addObject:model];
        }
    }
    
    NSLog(@"data...%@",data);
}

@end
