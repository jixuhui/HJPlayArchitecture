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
@property (nonatomic,strong) NSArray *modelsArray;
@property (nonatomic,strong) NSArray *curDrawModesArray;
@property (nonatomic) HJChartModelType *modelType;
@property (nonatomic) NSDictionary *layoutDic;
@property (nonatomic) long rangeFrom;
@property (nonatomic) long rangeSize;

@property (nonatomic) float paddingLeft;
@property (nonatomic) float paddingRight;
@property (nonatomic) float paddingTop;
@property (nonatomic) float paddingDown;

- (instancetype)initWithData:(NSArray *)array;
@end
