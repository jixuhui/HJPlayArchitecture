//
//  DemoBaseTableDataController.h
//  HJDemo
//
//  Created by jixuhui on 15/11/26.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "HJTableDataController.h"

@interface DemoBaseTableDataController : HJTableDataController

@end

@protocol DemoBaseTableDataControllerDelegate<HJDataControllerDelegate>

@optional
-(void) DemoBaseTableDataController:(DemoBaseTableDataController *) controller withCell:(UITableViewCell *)cell;

@end
