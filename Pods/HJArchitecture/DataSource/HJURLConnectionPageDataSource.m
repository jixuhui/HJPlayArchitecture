//
//  HJURLConnectionPageDataSource.m
//  Pods
//
//  Created by jixuhui on 15/12/2.
//
//

#import "HJURLConnectionPageDataSource.h"

@implementation HJURLConnectionPageDataSource

- (void)handleTask
{
    [[HJURLService shareService] handleTask:self success:[self getSuccessBlock] failure:[self getFailBlock]];
}

- (id)getSuccessBlock
{
    __weak __typeof(self)weakSelf = self;
    
    return ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf handleSuccessWithResponse:responseObject];
        
    };
}

- (id)getFailBlock
{
    __weak __typeof(self)weakSelf = self;
    
    return ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf handleFailureWithError:error];
        strongSelf.responseStatusCode = [[operation response] statusCode];
        
    };
}

@end
