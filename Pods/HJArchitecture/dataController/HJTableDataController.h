//
//  HJTableDataController.h
//  SinaNews
//
//  Created by jixuhui on 15/8/27.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HJDataController.h"
#import "HJPageURLDataSource.h"
#import "IHJViewBindDataProtocol.h"
#import "MJRefresh.h"
#import "HJActivityIndicatorCoverView.h"
#import "HJTableViewCell.h"

@protocol IHJTableDataController <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView * contentTableView;
@property(nonatomic,strong) MJRefreshNormalHeader * refreshControl;
@property(nonatomic,strong) MJRefreshBackNormalFooter * loadMoreControl;
@property(nonatomic,strong) HJActivityIndicatorCoverView * coverView;
@property(nonatomic,assign,getter=isLoading) BOOL loading;
@property(nonatomic,strong) NSString *cellClassName;
@property(nonatomic,assign) float cellHeight;

-(void)reloadDataWithCover;

@end

@interface HJTableDataController : HJDataController <IHJTableDataController>
{
    HJPageURLDataSource *_dataSource;
}

@end

@protocol HJTableDataControllerDelegate <HJDataControllerDelegate>

@optional

-(void) HJTableDataController:(HJTableDataController *) dataController didSelectRowAtIndexPath:(NSIndexPath *) indexPath;

-(void) HJTableDataController:(HJTableDataController *) dataController didSelectView:(id<IHJViewBindDataProtocol>) cell;

@end
