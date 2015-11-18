//
//  ViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/10/30.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "FirstViewController.h"
#import "TestTableViewCell.h"
#import "MASViewController.h"
#import <CoreSpotlight/CoreSpotlight.h>

@interface FirstViewController ()<HJTableDataControllerDelegate>

@end

@implementation FirstViewController

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
    
    [self.contentTableView deselectRowAtIndexPath:[self.contentTableView indexPathForSelectedRow] animated:YES];
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
    self.contentTableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.contentTableView.estimatedRowHeight = 60;
    self.contentTableView.rowHeight = UITableViewAutomaticDimension;
    self.contentTableView.delegate = self.tableDataController;
    self.contentTableView.dataSource = self.tableDataController;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentTableView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
    [self.view addSubview:self.contentTableView];
    
    self.tableDataController.contentTableView = self.contentTableView;
    
    WS(ws);
    
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view).with.insets(self.padding);
    }];
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
    [self setTabBarHidden:YES animated:YES];
    
    MASViewController *masVC = [[MASViewController alloc]init];
    [self.navigationController pushViewController:masVC animated:YES];
}

- (void)saveData{
    NSMutableArray *seachableItems = [NSMutableArray new];
    //必须copy下，直接用dataobjects 如果先delete后，搜索不到
    NSArray *tempArr = [self.tableDataController.dataSource.dataObjects mutableCopy ];
    [tempArr enumerateObjectsUsingBlock:^(NSDictionary *__nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"views"];
        attributeSet.title = @"AutoCar";
        attributeSet.contentDescription = [NSString stringWithFormat:NSLocalizedString(@"换行测试------------------------------- %@", nil),[obj dataForKey:@"name"]];
//        UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@.png",obj]];
//        attributeSet.thumbnailData = UIImagePNGRepresentation(thumbImage);//beta 1 there is a bug
        
        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[NSString stringWithFormat:@"20151118%lu",idx] domainIdentifier:@"com.sina.hubbert.demo.HJDemo" attributeSet:attributeSet];
        [seachableItems addObject:item];
    }];
    
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:seachableItems
                                                   completionHandler:^(NSError * __nullable error) {
                                                       if (!error)
                                                           NSLog(@"%@",error.localizedDescription);
                                                   }];
}

- (void)resetData{
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * __nullable error) {
        if (!error)
            NSLog(@"%@",error.localizedDescription);
    }];
    [self saveData];
}

- (void)deleteDataAtIndex:(NSInteger)index{
    NSString *identifier = [NSString stringWithFormat:@"20151118%lu",index];
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[identifier] completionHandler:^(NSError * __nullable error) {
        if (!error)
            NSLog(@"%@",error.localizedDescription);
    }];
}

#pragma mark - table data controller

-(void)HJDataControllerDidLoaded:(HJDataController *)controller
{
    [self resetData];
}

@end
