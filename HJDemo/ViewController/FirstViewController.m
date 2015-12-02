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
#import "DemoBaseTableDataController.h"
#import <CoreSpotlight/CoreSpotlight.h>

@interface FirstViewController ()<DemoBaseTableDataControllerDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)initManagers
{
    self.tableDataController = [[DemoBaseTableDataController alloc]init];
    self.tableDataController.delegate = self;
    self.tableDataController.cellClassName = @"TestTableViewCell";
    
    HJURLSessionPageDataSource *dataSource = [[HJURLSessionPageDataSource alloc]init];
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
    __block NSMutableArray *seachableItems = [[NSMutableArray alloc]initWithCapacity:5];
    [self.tableDataController.dataSource.dataObjects enumerateObjectsUsingBlock:^(NSDictionary *__nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"views"];
        attributeSet.title = @"AutoCar";
        attributeSet.contentDescription = [NSString stringWithFormat:NSLocalizedString(@"换行测试------------------------------- %@", nil),[obj dataForKey:@"name"]];
        UIImage *thumbImage = [UIImage imageNamed:@"tabbar_news.png"];
        attributeSet.thumbnailData = UIImagePNGRepresentation(thumbImage);//beta 1 there is a bug
        
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
    WS(ws);
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * __nullable error) {
        //必须放到block里保证删除结束后再去添加
        if (error){
            NSLog(@"%@",error.localizedDescription);
        }else {
            [ws saveData];
        }
    }];
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

-(void)DemoBaseTableDataController:(DemoBaseTableDataController *)controller withCell:(UITableViewCell *)cell
{
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        
        [self registerForPreviewingWithDelegate:(id)self sourceView:cell];
        
        // no need for our alternative anymore
        self.longPress.enabled = NO;
        
    } else {
        
        // handle a 3D Touch alternative (long gesture recognizer)
        self.longPress.enabled = YES;
        
    }
}

# pragma mark - 3D Touch Delegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    HJTableViewCell *cell = (HJTableViewCell *)[(id<UIViewControllerPreviewing>)previewingContext sourceView];
    NSLog(@"dataItem of cell...%@",cell.dataItem);
    
    UIViewController *previewController = [[MASViewController alloc]init];
    
    return previewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    [self setTabBarHidden:YES animated:YES];
    
    HJTableViewCell *cell = (HJTableViewCell *)[(id<UIViewControllerPreviewing>)previewingContext sourceView];
    NSLog(@"dataItem of cell...%@",cell.dataItem);
    
    [self showViewController:[[MASViewController alloc] init] sender:self];
    
}

#pragma mark - 3D Touch Alternative

- (void)showPeek {
    
    // disable gesture so it's not called multiple times
    self.longPress.enabled = NO;
    
    // present the preview view controller (peek)
    MASViewController *preview = [[MASViewController alloc]init];
    
    UIViewController *presenter = [self grabTopViewController];
    [presenter showViewController:preview sender:self];
    
}

- (UIViewController *)grabTopViewController {
    
    // helper method to always give the top most view controller
    // avoids "view is not in the window hierarchy" error
    // http://stackoverflow.com/questions/26022756/warning-attempt-to-present-on-whose-view-is-not-in-the-window-hierarchy-sw
    
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    
    return top;
}

@end
