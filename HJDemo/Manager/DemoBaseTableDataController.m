//
//  DemoBaseTableDataController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/26.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "DemoBaseTableDataController.h"

@implementation DemoBaseTableDataController

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(DemoBaseTableDataController:withCell:)]) {
        [self.delegate performSelector:@selector(DemoBaseTableDataController:withCell:) withObject:self withObject:cell];
    }
    
    return cell;
}

@end
