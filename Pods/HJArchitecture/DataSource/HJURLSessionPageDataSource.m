//
//  HJURLSessionPageDataSource.m
//  Pods
//
//  Created by jixuhui on 15/12/2.
//
//

#import "HJURLSessionPageDataSource.h"

@implementation HJURLSessionPageDataSource

- (void)handleTask
{
    [[HJURLService shareService] handleSessionTask:self success:[self getSuccessBlock] failure:[self getFailBlock]];
}

- (id)getSuccessBlock
{
    __weak __typeof(self)weakSelf = self;
    
    return ^(NSURLSessionDataTask *operation, id responseObject) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf handleSuccessWithResponse:responseObject];
        
    };
}

- (id)getFailBlock
{
    __weak __typeof(self)weakSelf = self;
    
    return ^(NSURLSessionDataTask *operation, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf handleFailureWithError:error];
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[operation response];
        strongSelf.responseStatusCode = [httpResponse statusCode];
        
    };
}

@end
