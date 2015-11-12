//
//  DemoManager.h
//  HJDemo
//
//  Created by jixuhui on 15/11/12.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDVTabBarController.h"

@interface DemoManager : NSObject
@property (nonatomic,strong)RDVTabBarController *tabBarContoller;
+(DemoManager *)shareManager;
@end
