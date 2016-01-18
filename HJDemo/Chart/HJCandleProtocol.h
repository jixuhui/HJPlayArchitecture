//
//  HJCandleProtocol.h
//  HJDemo
//
//  Created by jixuhui on 16/1/14.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HJCandleProtocol <NSObject>
@property (nonatomic) float openPrice;
@property (nonatomic) float closePrice;
@property (nonatomic) float adjClosePrice;
@property (nonatomic) float highPrice;
@property (nonatomic) float lowPrice;
@property (nonatomic) long volumn;
@property (nonatomic,strong) NSString * date;
@end
