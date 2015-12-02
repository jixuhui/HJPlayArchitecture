//
//  HJURLPageDataSource.h
//  SinaNews
//
//  Created by jixuhui on 15/8/31.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import "HJURLDataSource.h"
#import "HJURLPageTask.h"
#import "HJURLService.h"

@interface HJURLPageDataSource : HJURLDataSource <IHJURLPageTask>

@property(nonatomic,assign)NSInteger responseStatusCode;
@property(nonatomic,assign)NSInteger dataStatusCode;

- (void)loadMoreData;

- (void)handleTask;

- (id)getSuccessBlock;

- (id)getFailBlock;

- (void)handleSuccessWithResponse:(id)responseObject;

- (void)handleFailureWithError:(NSError *)error;

@end
