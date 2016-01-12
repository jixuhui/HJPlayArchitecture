//
//  ChartViewController.m
//  HJDemo
//
//  Created by jixuhui on 16/1/12.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "ChartViewController.h"

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
        NSLog(@"%@",result);
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
        NSArray   *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [category addObject:arr[0]];
        
        NSMutableArray *item =[[NSMutableArray alloc] init];
        [item addObject:arr[1]];
        [item addObject:arr[4]];
        [item addObject:arr[2]];
        [item addObject:arr[3]];
        [item addObject:arr[5]];
        [data addObject:item];
    }
}

@end
