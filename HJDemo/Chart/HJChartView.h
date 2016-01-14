//
//  HJChartView.h
//  HJDemo
//
//  Created by jixuhui on 16/1/14.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _HJChartModelType {
    HJChartModelTypeCandle = 0
}HJChartModelType;

@interface HJChartView : UIView
@property (nonatomic,strong) NSMutableArray *modelsArray;
@property (nonatomic) HJChartModelType *modelType;
@property (nonatomic) NSDictionary *layoutDic;
@end
