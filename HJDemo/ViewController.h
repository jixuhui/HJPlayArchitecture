//
//  ViewController.h
//  HJDemo
//
//  Created by jixuhui on 15/10/30.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJTableDataController.h"
#import "MJRefresh.h"
#import "HJActivityIndicatorCoverView.h"
#import "HJConstant.h"

@interface ViewController : UIViewController
{
    HJActivityIndicatorCoverView *coverView;
}

@property (nonatomic, strong) HJTableDataController *tableDataController;
@property (nonatomic, strong) UITableView*                      contentTableView;
@property (nonatomic, strong) MJRefreshNormalHeader*                 refreshControl;
@property (nonatomic, strong) MJRefreshBackNormalFooter*                loadMoreControl;

@end

