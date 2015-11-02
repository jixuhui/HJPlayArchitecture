//
//  HJURLTask.h
//  HJArchitecture
//
//  Created by jixuhui on 15/8/24.
//  Copyright (c) 2015年 private. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IHJURLTask <NSObject>

@property(nonatomic,copy) NSString *ID;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *urlString;
@property(nonatomic,copy) NSString *requestType;
@property(nonatomic,strong) NSMutableDictionary *otherParameters;
@property(nonatomic,strong) id operation;

@end

@interface HJURLTask : NSObject <IHJURLTask,NSCoding,NSCopying>

@end
