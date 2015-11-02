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
    });
    
    return _service;
}

-(AFHTTPRequestOperation *)handleTask:(HJURLTask *)task success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperation *operation = nil;
    
    if (!task.requestType) {
        task.requestType = @"get";
    }
    
    if ([[task.requestType uppercaseString] isEqualToString:@"GET"]) {
        operation = [super GET:task.urlString parameters:[task otherParameters] success:success failure:failure];
    }else if ([[task.requestType uppercaseString] isEqualToString:@"POST"]) {
        operation = [super POST:task.urlString parameters:[task otherParameters] success:success failure:failure];
    }
    
    task.operation = operation;
    [self.taskContainer addObject:task];
    
    return operation;
}

-(void)cancelTask:(id<IHJURLTask>)task
{
    if (![task conformsToProtocol:@protocol(IHJURLTask)]) {
        return;
    }
    
    AFHTTPRequestOperation *operation = [(id<IHJURLTask>)task operation];
    if (!operation.isCancelled) {
        [operation cancel];
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
