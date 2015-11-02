//
//  HJDataController.m
//  SinaNews
//
//  Created by jixuhui on 15/8/28.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import "HJDataController.h"

@implementation HJDataController
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;

-(void) dealloc{
    [_dataSource setDelegate:nil];
    [_dataSource cancel];
}

-(void) reloadData{
    [self.dataSource reloadData];
}

-(void) refreshData{
    [_dataSource refreshData];
}

-(void) cancel{
    [_dataSource cancel];
}

-(void) HJDataSourceWillLoading:(HJDataSource *) dataSource{
    if(dataSource == _dataSource){
        id delegate = self.delegate;
        if([delegate respondsToSelector:@selector(HJDataControllerWillLoading:)]){
            [delegate HJDataControllerWillLoading:self];
        }
    }
}

-(void) HJDataSourceDidLoaded:(HJDataSource *) dataSource{
    if(dataSource == _dataSource){
        
        id delegate = self.delegate;
        
        if([delegate respondsToSelector:@selector(HJDataControllerDidLoaded:)]){
            [delegate HJDataControllerDidLoaded:self];
        }
    }
}

-(void) HJDataSource:(HJDataSource *) dataSource didFitalError:(NSError *) error{
    if(dataSource == _dataSource){
        
        id delegate = self.delegate;
        
        if([delegate respondsToSelector:@selector(HJDataController:didFitalError:)]){
            [delegate HJDataController:self didFitalError:error];
        }
    }
}

-(void) HJDataSourceDidContentChanged:(HJDataSource *) dataSource{
    if(dataSource == _dataSource){
        
        id delegate = self.delegate;
        
        if([delegate respondsToSelector:@selector(HJDataControllerDidContentChanged:)]){
            [delegate HJDataControllerDidContentChanged:self];
        }
    }
}

-(void)setDataSource:(HJDataSource *)dataSource
{
    _dataSource = dataSource;
    _dataSource.delegate = self;
}

@end
