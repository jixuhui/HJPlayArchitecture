//
//  HJDataController.h
//  SinaNews
//
//  Created by jixuhui on 15/8/28.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HJDataSource.h"

@interface HJDataController : NSObject <HJDataSourceDelegate>

@property(nonatomic,strong) HJDataSource * dataSource;
@property(nonatomic,assign) id delegate;

-(void) refreshData;

-(void) reloadData;

-(void) cancel;

@end

@protocol HJDataControllerDelegate

@optional

-(void) HJDataControllerWillLoading:(HJDataController *) controller;

-(void) HJDataControllerDidLoadedFromCache:(HJDataController *) controller timestamp:(NSDate *) timestamp;

-(void) HJDataControllerDidLoaded:(HJDataController *) controller;

-(void) HJDataController:(HJDataController *) controller didFitalError:(NSError *) error;

-(void) HJDataControllerDidContentChanged:(HJDataController *) controller;

@end