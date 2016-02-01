//
//  HJChartViewModel.h
//  HJDemo
//
//  Created by jixuhui on 16/2/1.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HJChartModel.h"
#import "HJCandleChartModel.h"

typedef enum _CHART_MODEL_TYPE {
    CHART_MODEL_TYPE_DAY = 0,
    CHART_MODEL_TYPE_WEEK,
    CHART_MODEL_TYPE_MONTH
}CHART_MODEL_TYPE;

typedef enum _CHART_INFO_TYPE {
    CHART_INFO_TYPE_VOLUME = 0,
    CHART_INFO_TYPE_KDJ
}CHART_INFO_TYPE;

typedef enum _STOCK_FLAG {
    STOCK_FLAG_UP = 0,
    STOCK_FLAG_DOWN,
    STOCK_FLAG_MA5,
    STOCK_FLAG_MA10,
    STOCK_FLAG_MA30,
    STOCK_FLAG_MA60,
    STOCK_FLAG_DASH,
    STOCK_FLAG_DEFAULT
}STOCK_FLAG;

typedef enum _KDJ_FLAG {
    KDJ_FLAG_K = 0,
    KDJ_FLAG_D,
    KDJ_FLAG_J
}KDJ_FLAG;

@interface HJChartViewModel : NSObject

@property (nonatomic) CHART_MODEL_TYPE modelType;
@property (nonatomic) CHART_INFO_TYPE infoType;
@property (nonatomic,strong) NSArray *modelsArray;
@property (nonatomic,strong) NSArray *stockInfo;

@property (nonatomic) long rangeFrom;
@property (nonatomic) long rangeSize;

@property (nonatomic,strong) NSArray *curDrawModesArray;

@property (nonatomic,strong) NSDictionary *chartLineData;

@property (nonatomic,strong) NSArray *curMA5Array;
@property (nonatomic,strong) NSArray *curMA10Array;
@property (nonatomic,strong) NSArray *curMA30Array;
@property (nonatomic,strong) NSArray *curMA60Array;

@property (nonatomic,strong) NSArray *curKArray;
@property (nonatomic,strong) NSArray *curDArray;
@property (nonatomic,strong) NSArray *curJArray;

@property (nonatomic) float maxPrice;
@property (nonatomic) float minPrice;
@property (nonatomic) float averagePrice;
@property (nonatomic) long maxVolume;

@property (nonatomic) float maxKDJValue;
@property (nonatomic) float minKDJValue;

- (instancetype)initWithData:(NSArray *)array;
- (void)reCaculateChartData;
- (void)resetMe;

- (float)getHighPriceFromCandleArray:(NSArray *)candleArray;
- (float)getLowPriceFromCandleArray:(NSArray *)candleArray;
- (long)getMaxVolumeFromCurRange;
- (NSDictionary *)getMaxAndMinFromArray:(NSArray *)array;
- (float)getMaxFromArray:(NSArray *)array;
- (float)getMinFromArray:(NSArray *)array;

- (NSArray *)getDateINdexFromCurDrawCandleModels;
- (NSArray *)getDateIndexFromCandleModels:(NSArray *)modelsArray;

- (NSDictionary *)getTopInfoAttributesByFlag:(STOCK_FLAG)flag;
- (UIColor *)getColorByStockFlag:(STOCK_FLAG)flag;
- (UIColor *)getColorByKDJFlag:(KDJ_FLAG)flag;
- (UIColor *)getColorByCanleData:(HJCandleChartModel *)candleModel;
- (STOCK_FLAG)getStockFlagByCanleData:(HJCandleChartModel *)candleModel;
- (NSString *)getStringByFlag:(STOCK_FLAG)flag;
- (NSString *)transformToUnitWithVolume:(long)volume;
- (NSString *)transformToUnitWithVolume:(long)volume unitNum:(float)unitNum;
- (NSArray *)getMAArrayByFlag:(STOCK_FLAG)flag;
- (NSArray *)getKDJArrayByFlag:(KDJ_FLAG)flag;

@end
