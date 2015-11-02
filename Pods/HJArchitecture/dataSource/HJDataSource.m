//
//  HJDataSource.m
//  SinaNews
//
//  Created by jixuhui on 15/8/28.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import "HJDataSource.h"

@implementation HJDataSource
@synthesize dataObjects = _dataObjects;
@synthesize delegate = _delegate;
@synthesize loading = _loading;
@synthesize loaded = _loaded;
@synthesize dataKey = _dataKey;

-(instancetype) init{
    if((self = [super init])){
        
    }
    return self;
}

-(void) dealloc{
    [self cancel];
}

-(BOOL) isEmpty{
    return [_dataObjects count] == 0;
}

-(void) refreshData{
    [self reloadData];
}

-(void) reloadData{
    _loading = YES;
    if([_delegate respondsToSelector:@selector(HJDataSourceWillLoading:)]){
        [_delegate HJDataSourceWillLoading:self];
    }
}

-(void) cancel{
    _loading = NO;
}

-(NSInteger) count{
    return [self.dataObjects count];
}

-(NSMutableArray *) dataObjects{
    if(_dataObjects == nil){
        _dataObjects = [[NSMutableArray alloc] init];
    }
    return _dataObjects;
}

-(id) dataObjectAtIndex:(NSInteger) index{
    if(index>=0 && index < [self.dataObjects count]){
        return [self.dataObjects objectAtIndex:index];
    }
    return nil;
}


-(id) dataObject{
    if([self.dataObjects count ]>0){
        return [self.dataObjects objectAtIndex:0];
    }
    return nil;
}

-(void) loadResultsData:(id) resultsData{
    
    NSArray * items = _dataKey ? [resultsData dataForKeyPath:_dataKey] : resultsData;
    
    if([items isKindOfClass:[NSArray class]]){
        [[self dataObjects] addObjectsFromArray:items];
    }
    else if([items isKindOfClass:[NSDictionary class]]){
        [[self dataObjects] addObject:items];
    }
}

@end
