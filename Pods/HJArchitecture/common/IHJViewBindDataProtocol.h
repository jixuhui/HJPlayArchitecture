//
//  ISNEPViewBindDataProtocol.h
//  SinaNews
//
//  Created by jixuhui on 15/9/17.
//  Copyright (c) 2015年 sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IHJViewBindDataProtocol <NSObject>
@property(nonatomic,strong) NSString *actionName;
@property(nonatomic,strong) NSObject *dataItem;
@end
