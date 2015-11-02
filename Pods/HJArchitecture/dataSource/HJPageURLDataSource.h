//
//  HJPageURLDataSource.h
//  SinaNews
//
//  Created by jixuhui on 15/8/31.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import "HJURLDataSource.h"
#import "HJPageURLTask.h"

@interface HJPageURLDataSource : HJURLDataSource <IHJPageURLTask>
@property(nonatomic,assign)NSInteger responseStatusCode;
@property(nonatomic,assign)NSInteger dataStatusCode;
-(void) loadMoreData;
@end
