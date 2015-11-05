//
//  ViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/10/30.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "ViewController.h"

#import "TestTableViewCell.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.topItem.title = @"资讯";
    
    [self initManagers];
    [self initSubviews];
    
    [self.tableDataController reloadDataWithCover];
}

- (void)initManagers
{
    self.tableDataController = [[HJTableDataController alloc]init];
    self.tableDataController.delegate = self;
    self.tableDataController.cellClassName = @"TestTableViewCell";
    self.tableDataController.cellHeight = 60.0f;
    
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
//    CGRect tableFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
//    
//    _contentTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _contentTableView.delegate = self.tableDataController;
    _contentTableView.dataSource = self.tableDataController;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.backgroundView = nil;
    
    //    [_contentTableView sn_setInitialInsetsOfTop:self.tableEdgeInsets.top bottom:self.tableEdgeInsets.bottom];
    [self.view addSubview:_contentTableView];
    
    self.tableDataController.contentTableView = _contentTableView;
    
    _contentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //    _contentTableView.sn_scrollsToTop = YES;
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

@end
