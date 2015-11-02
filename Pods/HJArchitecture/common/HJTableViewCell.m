//
//  HJTableViewCell.m
//  HJArchitecture
//
//  Created by jixuhui on 15/10/9.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import "HJTableViewCell.h"

@interface HJTableViewCell()
@end

@implementation HJTableViewCell
@synthesize dataItem = _dataItem;
@synthesize actionName = _actionName;
@synthesize cellHeight = _cellHeight;

-(void)setDataItem:(NSObject *)dataItem
{
    if (![self.dataItem isEqual:dataItem]) {
        _dataItem = dataItem;
    }
}

@end
