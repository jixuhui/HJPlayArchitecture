//
//  ViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/10/30.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "ViewController.h"

#import "TestTableViewCell.h"

#import "MASViewController.h"

@interface ViewController ()<HJTableDataControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initManagers];
    [self initSubviews];
    
    [self.tableDataController reloadDataWithCover];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"资讯";
}

- (void)initManagers
{
    self.tableDataController = [[HJTableDataController alloc]init];
    self.tableDataController.delegate = self;
    self.tableDataController.cellClassName = @"TestTableViewCell";
    
    HJURLPageDataSource *dataSource = [[HJURLPageDataSource alloc]init];
    dataSource.urlString = SNEP_MiaoChe_URL_CarTypeList;
    dataSource.dataKey = @"content";
    dataSource.otherParameters = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dataSource.otherParameters setValue:@"110100" forKey:@"city_code"];
    [dataSource.otherParameters setValue:@"1080*920" forKey:@"resolution"];
    [dataSource.otherParameters setValue:@"442" forKey:@"series_id"];
    
    self.tableDataController.dataSource = dataSource;
    dataSource.delegate = self.tableDataController;
}

- (void)initSubviews
{
    [self initTableView];
    [self initRefreshControl];
    [self initLoadMoreControl];
    [self initCoverView];
}

- (void) initTableView
{
    self.contentTableView.estimatedRowHeight = 60;
    self.contentTableView.rowHeight = UITableViewAutomaticDimension;
    self.contentTableView.delegate = self.tableDataController;
    self.contentTableView.dataSource = self.tableDataController;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.contentTableView];
    
    self.tableDataController.contentTableView = self.contentTableView;
}

- (void) initRefreshControl
{
    _refreshControl = [[MJRefreshNormalHeader alloc] init];
    
    self.contentTableView.header = _refreshControl;
    
    self.tableDataController.refreshControl = _refreshControl;
}

- (void) initLoadMoreControl
{
    _loadMoreControl = [[MJRefreshBackNormalFooter alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kLoadMoreCellHeigth)];
    
    self.contentTableView.footer = _loadMoreControl;
    
    self.tableDataController.loadMoreControl = _loadMoreControl;
}

- (void)initCoverView
{
    coverView = [[HJActivityIndicatorCoverView alloc] initWithFrame:self.view.bounds style:HJActivityIndicatorCoverViewStyle_article];
    coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:coverView];
    
    self.tableDataController.coverView = coverView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)HJTableDataController:(HJTableDataController *)dataController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MASViewController *masVC = [[MASViewController alloc]init];
    [self.navigationController pushViewController:masVC animated:YES];
}

@end
