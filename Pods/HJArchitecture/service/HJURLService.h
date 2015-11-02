//
//  HJURLService.h
//  HJArchitecture
//
//  Created by jixuhui on 15/8/24.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "HJURLTask.h"

@class HJURLService;
@protocol IHJURLService <NSObject>

+(HJURLService *)shareService;
- (AFHTTPRequestOperation *)handleTask:(id<IHJURLTask>)task
                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
-(void)cancel;
-(void)cancelTask:(id<IHJURLTask>)task;
@end

@interface HJURLService : AFHTTPRequestOperationManager <IHJURLService>



@end
