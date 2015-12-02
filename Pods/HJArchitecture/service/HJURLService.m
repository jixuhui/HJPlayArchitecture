//
//  HJURLService.m
//  HJArchitecture
//
//  Created by jixuhui on 15/8/24.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import "HJURLService.h"

@interface HJURLService()
@property(nonatomic,strong)NSMutableArray *taskContainer;
@property(nonatomic,strong)AFHTTPRequestOperationManager *operationManager;
@property(nonatomic,strong)AFHTTPSessionManager *sessionManager;
@end

@implementation HJURLService
@synthesize taskContainer = _taskContainer;

+(HJURLService *)shareService
{
    static HJURLService *_service = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _service = [[HJURLService alloc] init];
        _service.taskContainer = [[NSMutableArray alloc]initWithCapacity:5];
        _service.operationManager = [[AFHTTPRequestOperationManager alloc]init];
        _service.sessionManager = [[AFHTTPSessionManager alloc]init];
    });
    
    return _service;
}

-(void)handleTask:(HJURLTask *)task
          success:(void (^)(AFHTTPRequestOperation *, id))success
          failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperation *operation = nil;
    
    if (!task.requestType) {
        task.requestType = @"get";
    }
    
    if ([[task.requestType uppercaseString] isEqualToString:@"GET"]) {
        operation = [self.operationManager GET:task.urlString parameters:[task otherParameters] success:success failure:failure];
    }else if ([[task.requestType uppercaseString] isEqualToString:@"POST"]) {
        operation = [self.operationManager POST:task.urlString parameters:[task otherParameters] success:success failure:failure];
    }
    
    task.operation = operation;
    [self.taskContainer addObject:task];
}

- (void)handleSessionTask:(id<IHJURLTask>)task
                  success:(void (^)(NSURLSessionDataTask *, id))success
                  failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSURLSessionDataTask *sessionDataTask = nil;
    
    if (!task.requestType) {
        task.requestType = @"get";
    }
    
    if ([[task.requestType uppercaseString] isEqualToString:@"GET"]) {
        sessionDataTask = [self.sessionManager GET:task.urlString parameters:[task otherParameters] success:success failure:failure];
    }else if ([[task.requestType uppercaseString] isEqualToString:@"POST"]) {
        sessionDataTask = [self.sessionManager POST:task.urlString parameters:[task otherParameters] success:success failure:failure];
    }
    
    task.operation = sessionDataTask;
    [self.taskContainer addObject:task];
}

-(void)cancelTask:(id<IHJURLTask>)task
{
    if (![task conformsToProtocol:@protocol(IHJURLTask)]) {
        return;
    }
    
    id operation = [(id<IHJURLTask>)task operation];
    
    if ([operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        AFHTTPRequestOperation *requestOperation = (AFHTTPRequestOperation *)operation;
        if (!requestOperation.isCancelled) {
            [requestOperation cancel];
        }
    }else if ([operation isKindOfClass:[NSURLSessionDataTask class]]) {
        NSURLSessionDataTask *sessionDataTask = (NSURLSessionDataTask *)operation;
        [sessionDataTask cancel];
    }
    
    if ([self.taskContainer containsObject:task]) {
        [self.taskContainer removeObject:task];
        task = nil;
    }
}

-(void)cancel
{
    for (id task in self.taskContainer) {
        [self cancelTask:task];
    }
}

@end
