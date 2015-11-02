//
//  HJTableDataController.h
//  SinaNews
//
//  Created by jixuhui on 15/8/27.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HJDataController.h"
#import "HJURLPageDataSource.h"
#import "IHJViewBindDataProtocol.h"
#import "MJRefresh.h"
#import "HJActivityIndicatorCoverView.h"
#import "HJTableViewCell.h"

@interface HJTableDataController : HJDataController <UITableViewDelegate,UITableViewDataSource>
{
    HJURLPageDataSource *_dataSource;
}
@property(nonatomic,strong) IBOutlet UITableView * contentTableView;
@property(nonatomic,strong) IBOutlet MJRefreshNormalHeader * refreshControl;
@property(nonatomic,strong) IBOutlet MJRefreshBackNormalFooter * loadMoreControl;
@property(nonatomic,strong) IBOutlet HJActivityIndicatorCoverView * coverView;
@property(nonatomic,assign,getter=isLoading) BOOL loading;
@property(nonatomic,strong) NSString *cellClassName;
@property(nonatomic,assign) float cellHeight;

-(void)reloadDataWithCover;
@end

@protocol HJTableDataControllerDelegate <HJDataControllerDelegate>

@optional

-(void) HJTableDataController:(HJTableDataController *) dataController didSelectRowAtIndexPath:(NSIndexPath *) indexPath;

-(void) HJTableDataController:(HJTableDataController *) dataController didSelectView:(id<IHJViewBindDataProtocol>) cell;

@end
