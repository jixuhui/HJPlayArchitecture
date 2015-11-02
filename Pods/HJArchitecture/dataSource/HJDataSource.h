//
//  HJDataSource.h
//  SinaNews
//
//  Created by jixuhui on 15/8/28.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+HJDataParse.h"

@protocol IHJDataSource

@property(nonatomic,getter = isLoading) BOOL loading;
@property(nonatomic,getter = isLoaded) BOOL loaded;
@property(nonatomic,readonly,getter = isEmpty) BOOL empty;
@property(nonatomic,strong) NSString * dataKey;
@property(nonatomic,strong) NSMutableArray * dataObjects;
@property(nonatomic,assign) id delegate;

-(void) refreshData;

-(void) reloadData;

-(void) cancel;

-(NSInteger) count;

-(id) dataObjectAtIndex:(NSInteger) index;

-(void) loadResultsData:(id) resultsData;

-(id) dataObject;

@end

@interface HJDataSource : NSObject <IHJDataSource>

@end

@protocol HJDataSourceDelegate

@optional

-(void) HJDataSourceWillLoading:(HJDataSource *) dataSource;

-(void) HJDataSourceDidLoadedFromCache:(HJDataSource *) dataSource timestamp:(NSDate *) timestamp;

-(void) HJDataSourceDidLoaded:(HJDataSource *) dataSource;

-(void) HJDataSource:(HJDataSource *) dataSource didFitalError:(NSError *) error;

-(void) HJDataSourceDidContentChanged:(HJDataSource *) dataSource;

@end
