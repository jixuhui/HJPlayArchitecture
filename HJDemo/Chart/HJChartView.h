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

@property(assign,nonatomic) BOOL transformed;

@property (nonatomic,strong) NSArray *modelsArray;
@property (nonatomic,strong) NSArray *curDrawModesArray;
@property (nonatomic) HJChartModelType *modelType;
@property (nonatomic) NSDictionary *layoutDic;
@property (nonatomic) long rangeFrom;
@property (nonatomic) long rangeSize;

//price pricePadding
@property (nonatomic) float pricePaddingLeft;
@property (nonatomic) float pricePaddingRight;
@property (nonatomic) float pricePaddingTop;
@property (nonatomic) float pricePaddingDown;

@property (nonatomic) float volumePaddingTop;
@property (nonatomic) float volumePaddingDown;

- (instancetype)initWithData:(NSArray *)array;
- (void)renderMe;

@end
