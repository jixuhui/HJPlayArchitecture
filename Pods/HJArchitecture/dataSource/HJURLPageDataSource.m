//
//  HJURLPageDataSource.m
//  SinaNews
//
//  Created by jixuhui on 15/8/31.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import "HJURLPageDataSource.h"
#import "HJURLService.h"

@implementation HJURLPageDataSource
{
    Class _originalClass;
}

@synthesize pageIndex = _pageIndex;
@synthesize pageSize = _pageSize;
@synthesize hasMoreData = _hasMoreData;
@synthesize pageIndexKey = _pageIndexKey;
@synthesize pageSizeKey = _pageSizeKey;
@synthesize otherParameters = _otherParameters;

Class object_getClass(id object);

-(id) init{
    if((self = [super init])){
        self.pageIndex = 1;
        self.pageSize = 10;
        self.pageIndexKey = @"page";
        self.pageSizeKey = @"pagesize";
    }
    return self;
}

- (void)setDelegate:(id)delegate
{
    [super setDelegate:delegate];
    _originalClass = object_getClass(delegate);
}

-(void) reloadData{
    
    [super reloadData];
    
    if(self.pageIndex !=1){
        self.pageIndex = 1;
    }
    
    [[HJURLService shareService] cancelTask:self];
    
    [self.otherParameters setValue:[NSString stringWithFormat:@"%d",self.pageIndex] forKey:self.pageIndexKey];
    
    [self.otherParameters setValue:[NSString stringWithFormat:@"%d",self.pageSize] forKey:self.pageSizeKey];
    
    __weak __typeof(self)weakSelf = self;
    
    [[HJURLService shareService] handleTask:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.loading = NO;
        
        if(_pageIndex == 1){
            [[strongSelf dataObjects] removeAllObjects];
        }
        
        [strongSelf loadResultsData:responseObject];
        
        Class currentClass = object_getClass(self.delegate);
        if (currentClass == _originalClass) {
            if(strongSelf.delegate&&[strongSelf.delegate respondsToSelector:@selector(HJDataSourceDidLoaded:)]){
                [strongSelf.delegate HJDataSourceDidLoaded:strongSelf];
            }
        }else{
            strongSelf.delegate = strongSelf;
        }
        
        strongSelf.loaded = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.loading = NO;
        if([strongSelf.delegate respondsToSelector:@selector(HJDataSource:didFitalError:)]){
            [strongSelf.delegate HJDataSource:strongSelf didFitalError:error];
        }
        if([[strongSelf dataObjects] count]){
            strongSelf.loaded = YES;
        }
    }];
}

-(void) loadMoreData{
    
    self.pageIndex ++;
    self.loading = YES;
    
    if([self.delegate respondsToSelector:@selector(HJDataSourceWillLoading:)]){
        [self.delegate HJDataSourceWillLoading:self];
    }
    
    [self.otherParameters setValue:[NSString stringWithFormat:@"%d",self.pageIndex] forKey:self.pageIndexKey];
    
    [self.otherParameters setValue:[NSString stringWithFormat:@"%d",self.pageSize] forKey:self.pageSizeKey];
    
    __weak __typeof(self)weakSelf = self;
    
    [[HJURLService shareService] handleTask:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.loading = NO;
        
        if(_pageIndex == 1){
            [[strongSelf dataObjects] removeAllObjects];
        }
        
        [strongSelf loadResultsData:responseObject];
        
        Class currentClass = object_getClass(self.delegate);
        if (currentClass == _originalClass) {
            if(strongSelf.delegate&&[strongSelf.delegate respondsToSelector:@selector(HJDataSourceDidLoaded:)]){
                [strongSelf.delegate HJDataSourceDidLoaded:strongSelf];
            }
        }else{
            strongSelf.delegate = strongSelf;
        }
        
        strongSelf.loaded = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.loading = NO;
        if([strongSelf.delegate respondsToSelector:@selector(HJDataSource:didFitalError:)]){
            [strongSelf.delegate HJDataSource:strongSelf didFitalError:error];
        }
        if([[strongSelf dataObjects] count]){
            strongSelf.loaded = YES;
        }
        
        strongSelf.responseStatusCode = [[operation response] statusCode];
    }];
}

-(void) loadResultsData:(id)resultsData{
    
    NSUInteger c = [self count];
    
    [super loadResultsData:resultsData];
    
    self.hasMoreData = [self count] != c;
    
}

-(void)cancel
{
    [super cancel];
    [[HJURLService shareService] cancelTask:self];
}

@end
