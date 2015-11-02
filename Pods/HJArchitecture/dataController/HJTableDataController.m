//
//  HJTableDataController.m
//  SinaNews
//
//  Created by jixuhui on 15/8/27.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import "HJTableDataController.h"
#import "HJTableViewCell.h"
#import "AFNetworking.h"
#import "HJConstant.h"

@interface HJTableDataController()

@end

@implementation HJTableDataController
//public
@synthesize contentTableView = _contentTableView;
@synthesize refreshControl = _refreshControl;
@synthesize loadMoreControl = _loadMoreControl;
@synthesize coverView = _coverView;
@synthesize loading = _loading;
@synthesize cellClassName = _cellClassName;
@synthesize cellHeight = _cellHeight;
//private

#pragma mark - life cycle

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.cellHeight = 60;
    }
    return self;
}

-(void)cancel
{
    [super cancel];
    [self stopLoading];
}

- (void)reloadDataWithCover
{
    [self.coverView startAnimating];
    [self reloadData];
}

-(void)setDataSource:(HJDataSource *)dataSource
{
    [super setDataSource:dataSource];
    
    if ([self.dataSource isKindOfClass:[HJURLDataSource class]]) {
        _dataSource = (HJURLPageDataSource *)self.dataSource;
    }else{
        _dataSource = nil;
    }
}

#pragma mark - refresh control

-(void)setRefreshControl:(MJRefreshNormalHeader *)refreshControl
{
    _refreshControl = refreshControl;
    [_refreshControl setRefreshingTarget:self refreshingAction:@selector(triggerRefresh)];
}

- (void)triggerRefresh
{
    if (self.isLoading) {
        return;
    }
    
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        self.loading = NO;
        return ;
    }
    else
    {
        self.loading = YES;
    }
    
    [self reloadData];
}

#pragma mark - loadmore control

-(void)setLoadMoreControl:(MJRefreshBackNormalFooter *)loadMoreControl
{
    _loadMoreControl = loadMoreControl;
    [_loadMoreControl setRefreshingTarget:self refreshingAction:@selector(triggerLoadMore)];
}

- (void)triggerLoadMore
{
    if(self.isLoading)
    {
        return;
    }
    
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        self.loading = NO;
        return ;
    }
    else
    {
        self.loading = YES;
    }
    
    [self loadMoreData];
}

- (void)loadMoreData
{
    if([_dataSource respondsToSelector:@selector(hasMoreData)] && [(id)_dataSource hasMoreData]
       && ![_dataSource isLoading]){
        [_dataSource performSelectorOnMainThread:@selector(loadMoreData) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource.dataObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HJTableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        if (CHECK_VALID_STRING(self.cellClassName)) {
            Class cellClass = NSClassFromString(self.cellClassName);
            cell = [[cellClass alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }else{
            cell = [[HJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
    }
    
    [cell setDataItem:[_dataSource.dataObjects objectAtIndex:indexPath.row]];
    [cell setCellHeight:self.cellHeight];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.delegate respondsToSelector:@selector(HJTableDataController:didSelectRowAtIndexPath:)]){
        [self.delegate HJTableDataController:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - datasource delegate

-(void) HJDataSourceWillLoading:(HJDataSource *)dataSource{
    [self startLoading];
    [super HJDataSourceWillLoading:dataSource];
}

-(void) HJDataSourceDidLoadedFromCache:(HJDataSource *) dataSource timestamp:(NSDate *) timestamp{
    [self.contentTableView reloadData];
    [super HJDataSourceDidLoadedFromCache:dataSource timestamp:timestamp];
}

-(void) HJDataSourceDidLoaded:(HJDataSource *) dataSource{
    [self.contentTableView reloadData];
    [self stopLoading];
    
    [super HJDataSourceDidLoaded:dataSource];
        
    if (_dataSource.pageIndex <= 1)
    {
        if ([_dataSource.dataObjects count] == 0)
        {
            [self.coverView stopAnimationWithRetryAction:@selector(reloadDataWithCover) withActObject:self];
            return;
        }else{
            [self.coverView stopAnimating];
        }
    }
    
    [self getNewsChannelDataSuccess];
}

-(void) HJDataSource:(HJURLDataSource *)dataSource didFitalError:(NSError *)error{
    [self stopLoading];
    [super HJDataSource:dataSource didFitalError:error];
    
    if(_dataSource.responseStatusCode != 200)
    {
        if (_dataSource.pageIndex <= 1)
        {
            if ([_dataSource.dataObjects count] > 0)
            {
                [self.coverView stopAnimating];
                //                [TipHandler showNetWorkFailedOnlyTextWithResponseStatus:_dataSource.responseStatusCode];
                return ;
            }
            else
            {
                [self.coverView stopAnimationWithRetryAction:@selector(reloadDataWithCover) withActObject:self];
            }
            
        }
        else
        {
            //提示网络有问题
            //            [TipHandler showNetWorkFailedOnlyTextWithResponseStatus:_dataSource.responseStatusCode];
            return ;
        }
        
    }else{
        if (_dataSource.pageIndex <= 1)
        {
            if ([_dataSource.dataObjects count] > 0)
            {
                [self.coverView stopAnimating];
//                [TipHandler showDataErrorTextOnly];
            }
            else
            {
                [self.coverView stopAnimationWithRetryAction:@selector(reloadDataWithCover) withActObject:self];
            }
        }
        else{
            //提示解析时数据错误
            //            [TipHandler showDataErrorTextOnly];
            return;
        }
    }
    
    [self getNewsChannelDataSuccess];
}

#pragma mark - help

- (void) getNewsChannelDataSuccess
{
    if(!([_dataSource respondsToSelector:@selector(hasMoreData)]
       && [(id)_dataSource hasMoreData]))
    {
        _contentTableView.footer = nil;
        return ;
    }
    
    if(_dataSource.pageIndex == 1)
    {
        if(_dataSource.dataObjects.count == _dataSource.pageSize)
        {
            [self addFooterViewForMoreData];
        }
        else
        {
            _contentTableView.footer = nil;
        }
    }
    else
    {
        if([_dataSource.dataObjects count] >0)
        {
            [self addFooterViewForMoreData];
        }
    }
}

-(void)addFooterViewForMoreData
{
    self.loading = NO;
    _contentTableView.footer = _loadMoreControl;
    [self.contentTableView reloadData];
}

-(void)startLoading
{
    if(![(id)_dataSource respondsToSelector:@selector(pageIndex)]
       || [(id)_dataSource pageIndex] == 1){
        self.loading = YES;
    }else{
        self.loading = NO;
    }
}

-(void)stopLoading
{
    self.loading = NO;
    [self.refreshControl endRefreshing];
    [self.loadMoreControl endRefreshing];
}

@end
