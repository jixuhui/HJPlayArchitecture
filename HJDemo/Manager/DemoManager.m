//
//  DemoManager.m
//  HJDemo
//
//  Created by jixuhui on 15/11/12.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "DemoManager.h"

@implementation DemoManager

+(DemoManager *)shareManager
{
    static DemoManager *staticManager;
    static dispatch_once_t oncePredicat;
    dispatch_once(&oncePredicat, ^{
        staticManager = [[DemoManager alloc]init];
    });
    
    return staticManager;
}

@end
