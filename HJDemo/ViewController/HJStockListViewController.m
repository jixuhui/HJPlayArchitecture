//
//  HJStockListViewController.m
//  HJDemo
//
//  Created by jixuhui on 16/1/28.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "HJStockListViewController.h"
#import "JSONKit.h"
#import "ChartViewController.h"

@interface HJStockListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *contentTableView;
@property (nonatomic,strong) NSMutableArray *stockArray;
@end

@implementation HJStockListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getStockListData];
    [self initSubviews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"股票列表";
    
    [self.contentTableView deselectRowAtIndexPath:[self.contentTableView indexPathForSelectedRow] animated:YES];
}

- (void)initSubviews
{
    [self initTableView];
}

- (void) initTableView
{
    self.contentTableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self.view addSubview:self.contentTableView];
    
    [self.contentTableView reloadData];
}

-(void)getStockListData{
    NSString *securities =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"securities" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *data = [securities mutableObjectFromJSONString];
    self.stockArray = data;
}
#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stockArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *item = [self.stockArray objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        float left = 15.0f;
        float top = 10.0f;
        float width = (kScreenWidth - left*2)/2;
        float height = 30.0f;
        
        UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, height)];
        codeLabel.textAlignment = NSTextAlignmentLeft;
        codeLabel.tag = 0;
        [cell.contentView addSubview:codeLabel];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left+width, top, width, height)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.tag = 1;
        [cell.contentView addSubview:nameLabel];
    }
    
    for (UILabel *label in cell.contentView.subviews) {
        if (label.tag==0) {
            label.text = [item firstObject];
        }else if(label.tag==1) {
            label.text = [item lastObject];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChartViewController *chartVC = [[ChartViewController alloc]initWithStockInfo:[self.stockArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:chartVC animated:YES];
}

@end
