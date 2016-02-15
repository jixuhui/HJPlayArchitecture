//
//  HJChartViewModel.m
//  HJDemo
//
//  Created by jixuhui on 16/2/1.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "HJChartViewModel.h"

@interface HJChartViewModel()

@end

@implementation HJChartViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rangeSize = 80;
        self.rangeFrom = -1;
    }
    return self;
}

- (instancetype)initWithData:(NSArray *)array
{
    self = [self init];
    if (self) {
        self.modelsArray = array;
    }
    return self;
}

- (void)reCaculateChartData
{
    if (self.rangeFrom == -1) {
        self.rangeFrom = [self.modelsArray count] - self.rangeSize;
    }
    
    //重新获取当前需要绘制的Candle数据
    NSIndexSet *se = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rangeFrom, self.rangeSize)];
    self.curDrawModesArray = [self.modelsArray objectsAtIndexes:se];
    
    //重新获取当前需要绘制的MA数据
    NSIndexSet *maSe = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rangeFrom-1, self.rangeSize+1)];
    if (self.rangeFrom == 0) {
        maSe = se;
    }
    self.curMA5Array = [(NSArray *)[self.chartLineData dataForKey:@"ma5"] objectsAtIndexes:maSe];
    self.curMA10Array = [(NSArray *)[self.chartLineData dataForKey:@"ma10"] objectsAtIndexes:maSe];
    self.curMA30Array = [(NSArray *)[self.chartLineData dataForKey:@"ma30"] objectsAtIndexes:maSe];
    self.curMA60Array = [(NSArray *)[self.chartLineData dataForKey:@"ma60"] objectsAtIndexes:maSe];
    
    NSString *maxHighPrice = [NSString stringWithFormat:@"%f",[self getHighPriceFromCandleArray:self.curDrawModesArray]];
    NSString *minLowPrice = [NSString stringWithFormat:@"%f",[self getLowPriceFromCandleArray:self.curDrawModesArray]];
    NSDictionary *ma5Dic = [self getMaxAndMinFromArray:self.curMA5Array];
    NSDictionary *ma10Dic = [self getMaxAndMinFromArray:self.curMA10Array];
    NSDictionary *ma30Dic = [self getMaxAndMinFromArray:self.curMA30Array];
    NSDictionary *ma60Dic = [self getMaxAndMinFromArray:self.curMA60Array];
    
    NSArray *maxArr = @[maxHighPrice,ma5Dic[@"max"],ma10Dic[@"max"],ma30Dic[@"max"],ma60Dic[@"max"]];
    NSArray *minArr = @[minLowPrice,ma5Dic[@"min"],ma10Dic[@"min"],ma30Dic[@"min"],ma60Dic[@"min"]];
    
    //price
    self.maxPrice = [self getMaxFromArray:maxArr];
    self.minPrice = [self getMinFromArray:minArr];
    self.averagePrice = (self.maxPrice + self.minPrice)/2;
    
    //volume
    self.maxVolume = [self getMaxVolumeFromCurRange];
    
    //kdj
    self.curKArray = [(NSArray *)[self.chartLineData dataForKey:@"kdj_k"] objectsAtIndexes:maSe];
    self.curDArray = [(NSArray *)[self.chartLineData dataForKey:@"kdj_d"] objectsAtIndexes:maSe];
    self.curJArray = [(NSArray *)[self.chartLineData dataForKey:@"kdj_j"] objectsAtIndexes:maSe];
    
    NSDictionary *kDic = [self getMaxAndMinFromArray:self.curKArray];
    NSDictionary *dDic = [self getMaxAndMinFromArray:self.curDArray];
    NSDictionary *jDic = [self getMaxAndMinFromArray:self.curJArray];
    NSArray *maxKDJArr = @[kDic[@"max"],dDic[@"max"],jDic[@"max"]];
    NSArray *minKDJArr = @[kDic[@"min"],dDic[@"min"],jDic[@"min"]];
   
    self.maxKDJValue = [self getMaxFromArray:maxKDJArr];
    self.minKDJValue = [self getMinFromArray:minKDJArr];
    
    //rsi
    self.curRSI6Array = [(NSArray *)[self.chartLineData dataForKey:@"rsi6"] objectsAtIndexes:maSe];
    self.curRSI12Array = [(NSArray *)[self.chartLineData dataForKey:@"rsi12"] objectsAtIndexes:maSe];
    self.curRSI24Array = [(NSArray *)[self.chartLineData dataForKey:@"rsi24"] objectsAtIndexes:maSe];
    
    NSDictionary *rsi6Dic = [self getMaxAndMinFromArray:self.curRSI6Array];
    NSDictionary *rsi12Dic = [self getMaxAndMinFromArray:self.curRSI12Array];
    NSDictionary *rsi24Dic = [self getMaxAndMinFromArray:self.curRSI24Array];
    NSArray *maxRSIArr = @[rsi6Dic[@"max"],rsi12Dic[@"max"],rsi24Dic[@"max"]];
    NSArray *minRSIArr = @[rsi6Dic[@"min"],rsi12Dic[@"min"],rsi24Dic[@"min"]];
    
    self.maxRSIValue = [self getMaxFromArray:maxRSIArr];
    self.minRSIValue = [self getMinFromArray:minRSIArr];
}

- (void)setModelsArray:(NSArray *)modelsArray
{
    _modelsArray = modelsArray;
    self.chartLineData = [self transformChartLineData];
}

- (void)resetMe
{
    self.rangeFrom = -1;
    self.modelsArray = nil;
    self.curDrawModesArray = nil;
    
    self.chartLineData = nil;
    
    self.curMA5Array = nil;
    self.curMA10Array = nil;
    self.curMA30Array = nil;
    self.curMA60Array = nil;
    
    self.curKArray = nil;
    self.curDArray = nil;
    self.curJArray = nil;
    
    self.curRSI6Array = nil;
    self.curRSI12Array = nil;
    self.curRSI24Array = nil;
}

#pragma mark - help methods


- (NSDictionary *)transformChartLineData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    //MA
    dic[@"ma5"] = [self calculateMAWithDays:5];
    dic[@"ma10"] = [self calculateMAWithDays:10];
    dic[@"ma30"] = [self calculateMAWithDays:30];
    dic[@"ma60"] = [self calculateMAWithDays:60];
    
    //RSI
    dic[@"rsi6"] = [self calculateRSIWithDays:6];
    dic[@"rsi12"] = [self calculateRSIWithDays:12];
    dic[@"rsi24"] = [self calculateRSIWithDays:24];
    
    //KDJ
    NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
    NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
    NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
    float prev_k = 50;
    float prev_d = 50;
    float rsv = 0;
    for(int i = 0;i < self.modelsArray.count;i++){
        
        float k = 50.0f;
        float d = 50.0f;
        float j = 50.0f;
        
        if (i>=8) {
            
            NSIndexSet *se = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i-8, 9)];
            NSArray *curArray = [self.modelsArray objectsAtIndexes:se];
            
            float h = [self getHighPriceFromCandleArray:curArray];
            float l = [self getLowPriceFromCandleArray:curArray];
            float c = [[curArray lastObject] closePrice];
            
            if(h!=l)
                rsv = (c-l)/(h-l)*100;
            k = 2*prev_k/3+1*rsv/3;
            d = 2*prev_d/3+1*k/3;
            j = 3*k-2*d;
        }
        
        prev_k = k;
        prev_d = d;
        
        [kdj_k addObject:[@"" stringByAppendingFormat:@"%f",k]];
        [kdj_d addObject:[@"" stringByAppendingFormat:@"%f",d]];
        [kdj_j addObject:[@"" stringByAppendingFormat:@"%f",j]];
    }
    dic[@"kdj_k"] = kdj_k;
    dic[@"kdj_d"] = kdj_d;
    dic[@"kdj_j"] = kdj_j;
    
    //    //VR
    //    NSMutableArray *vr = [[NSMutableArray alloc] init];
    //    for(int i = 60;i < data.count;i++){
    //        float inc = 0;
    //        float dec = 0;
    //        float eq  = 0;
    //        for(int j=i;j>i-24;j--){
    //            float o = [[data[j] objectAtIndex:0] floatValue];
    //            float c = [[data[j] objectAtIndex:1] floatValue];
    //
    //            if(c > o){
    //                inc += [[data[j] objectAtIndex:4] intValue];
    //            }else if(c < o){
    //                dec += [[data[j] objectAtIndex:4] intValue];
    //            }else{
    //                eq  += [[data[j] objectAtIndex:4] intValue];
    //            }
    //        }
    //        
    //        float val = (inc+1*eq/2)/(dec+1*eq/2);
    //        NSMutableArray *item = [[NSMutableArray alloc] init];
    //        [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
    //        [vr addObject:item];
    //    }
    //    dic[@"vr"] = vr;
    
    return dic;
}

- (NSArray *)calculateMAWithDays:(int)dayNum
{
    NSMutableArray *maArray = [[NSMutableArray alloc] init];
    for(int i = 0;i < self.modelsArray.count;i++){
        float val = 0;
        
        int minValue = i>=dayNum-1?i-(dayNum-1):0;
        
        for(int j=i;j>=minValue;j--){
            HJCandleChartModel *chartModel = self.modelsArray[j];
            val += chartModel.closePrice;
        }
        
        val = val/dayNum;
        [maArray addObject:[@"" stringByAppendingFormat:@"%f",val]];
    }
    
    return maArray;
}

- (NSArray *)calculateRSIWithDays:(int)dayNum
{
    NSMutableArray *rsiArray = [[NSMutableArray alloc] init];
    
    for(int i = 0;i < self.modelsArray.count;i++){
        
        float incVal  = 0;
        
        float decVal = 0;
        
        float rs = 0;
        
        int min = i-dayNum+1>=0?i-dayNum+1:0;
        
        for(int j=i;j>=min;j--){
            HJCandleChartModel *model = (HJCandleChartModel *)[self.modelsArray objectAtIndex:j];
            float interval = model.closePrice-model.openPrice;
            if(interval >= 0){
                incVal += interval;
            }else{
                decVal -= interval;
            }
        }
        rs = incVal/decVal;
        float rsi =100-100/(1+rs);
        [rsiArray addObject:[@""stringByAppendingFormat:@"%f",rsi]];
        
    }
    
    return rsiArray;
}

- (float)getHighPriceFromCandleArray:(NSArray *)candleArray
{
    NSComparator cmptr = ^(HJCandleChartModel *obj1, HJCandleChartModel *obj2){
        
        if ([obj1 highPrice] > [obj2 highPrice]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 highPrice] < [obj2 highPrice]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *array = [candleArray sortedArrayUsingComparator:cmptr];
    HJCandleChartModel *highModel = [array lastObject];
    return highModel.highPrice;
}

- (float)getLowPriceFromCandleArray:(NSArray *)candleArray
{
    NSComparator cmptr = ^(HJCandleChartModel *obj1, HJCandleChartModel *obj2){
        
        if ([obj1 lowPrice] < [obj2 lowPrice]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 lowPrice] > [obj2 lowPrice]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *array = [candleArray sortedArrayUsingComparator:cmptr];
    HJCandleChartModel *lowModel = [array lastObject];
    return lowModel.lowPrice;
}

- (long)getMaxVolumeFromCurRange
{
    NSComparator cmptr = ^(HJCandleChartModel *obj1, HJCandleChartModel *obj2){
        
        if ([obj1 volume] > [obj2 volume]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 volume] < [obj2 volume]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *array = [self.curDrawModesArray sortedArrayUsingComparator:cmptr];
    HJCandleChartModel *highModel = [array lastObject];
    return highModel.volume;
}

- (NSDictionary *)getMaxAndMinFromArray:(NSArray *)array
{
    NSComparator cmptr = ^(id obj1, id obj2){
        
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *sortedArray = [array sortedArrayUsingComparator:cmptr];
    return @{@"max":[sortedArray lastObject],@"min":[sortedArray firstObject]};
}

- (float)getMaxFromArray:(NSArray *)array
{
    NSComparator cmptr = ^(id obj1, id obj2){
        
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *sortedArray = [array sortedArrayUsingComparator:cmptr];
    return [[sortedArray lastObject] floatValue];
}

- (float)getMinFromArray:(NSArray *)array
{
    NSComparator cmptr = ^(id obj1, id obj2){
        
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *sortedArray = [array sortedArrayUsingComparator:cmptr];
    return [[sortedArray lastObject] floatValue];
}

- (NSArray *)getDateINdexFromCurDrawCandleModels
{
    return [self getDateIndexFromCandleModels:self.curDrawModesArray];
}

- (NSArray *)getDateIndexFromCandleModels:(NSArray *)modelsArray
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:5];
    
    switch (self.modelType) {
        case CHART_MODEL_TYPE_DAY:
        {
            for (int i=0; i<[modelsArray count]-1; i++) {
                HJCandleChartModel *leftModel = [modelsArray objectAtIndex:i];
                HJCandleChartModel *rightModel = [modelsArray objectAtIndex:i+1];
                
                NSArray *leftDateArr = [leftModel.date componentsSeparatedByString:@"-"];
                NSArray *rightDateArr = [rightModel.date componentsSeparatedByString:@"-"];
                
                if (CHECK_VALID_ARRAY(leftDateArr) && CHECK_VALID_ARRAY(rightDateArr) && [leftDateArr count]==3 && [rightDateArr count]==3) {
                    if (![[leftDateArr objectAtIndex:1] isEqualToString:[rightDateArr objectAtIndex:1]]) {
                        [array addObject:[NSNumber numberWithInt:i+1]];
                    }
                }
            }
        }
            break;
        case CHART_MODEL_TYPE_WEEK:
        {
            for (int i=0; i<[modelsArray count]-1; i++) {
                HJCandleChartModel *leftModel = [modelsArray objectAtIndex:i];
                HJCandleChartModel *rightModel = [modelsArray objectAtIndex:i+1];
                
                NSArray *leftDateArr = [leftModel.date componentsSeparatedByString:@"-"];
                NSArray *rightDateArr = [rightModel.date componentsSeparatedByString:@"-"];
                
                if (CHECK_VALID_ARRAY(leftDateArr) && CHECK_VALID_ARRAY(rightDateArr) && [leftDateArr count]==3 && [rightDateArr count]==3) {
                    if (![[leftDateArr objectAtIndex:1] isEqualToString:[rightDateArr objectAtIndex:1]]) {
                        int monthValue = [[rightDateArr objectAtIndex:1] intValue];
                        if (monthValue % 2 == 1) {
                            [array addObject:[NSNumber numberWithInt:i+1]];
                        }
                    }
                }
            }
        }
            break;
        case CHART_MODEL_TYPE_MONTH:
        {
            for (int i=0; i<[modelsArray count]-1; i++) {
                HJCandleChartModel *leftModel = [modelsArray objectAtIndex:i];
                HJCandleChartModel *rightModel = [modelsArray objectAtIndex:i+1];
                
                NSArray *leftDateArr = [leftModel.date componentsSeparatedByString:@"-"];
                NSArray *rightDateArr = [rightModel.date componentsSeparatedByString:@"-"];
                
                if (CHECK_VALID_ARRAY(leftDateArr) && CHECK_VALID_ARRAY(rightDateArr) && [leftDateArr count]==3 && [rightDateArr count]==3) {
                    if (![[leftDateArr objectAtIndex:0] isEqualToString:[rightDateArr objectAtIndex:0]]) {
                        [array addObject:[NSNumber numberWithInt:i+1]];
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    return array;
}

- (NSDictionary *)getTopInfoAttributesByFlag:(STOCK_FLAG)flag
{
    UIFont *font = [UIFont systemFontOfSize:12];
    UIColor *color = [self getColorByStockFlag:flag];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    return attributes;
}

- (UIColor *)getColorByStockFlag:(STOCK_FLAG)flag
{
    switch (flag) {
        case STOCK_FLAG_DEFAULT:
            return [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:0.8f];
            break;
        case STOCK_FLAG_UP:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
        case STOCK_FLAG_DOWN:
            return [UIColor colorWithRed:0.15 green:0.6 blue:0.1 alpha:1];
            break;
        case STOCK_FLAG_MA5:
            return [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
            break;
        case STOCK_FLAG_MA10:
            return [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
            break;
        case STOCK_FLAG_MA30:
            return [UIColor colorWithRed:1 green:0 blue:1 alpha:1];
            break;
        case STOCK_FLAG_MA60:
            return [UIColor colorWithRed:0.8 green:0.04 blue:0.05 alpha:1];
            break;
        case STOCK_FLAG_DASH:
            return [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5];
            break;
        default:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
    }
}


- (UIColor *)getColorByKDJFlag:(KDJ_FLAG)flag
{
    switch (flag) {
        case KDJ_FLAG_K:
            return [UIColor colorWithRed:0.18f green:0.69f blue:0.19f alpha:0.8f];
            break;
        case KDJ_FLAG_D:
            return [UIColor colorWithRed:0.94f green:0.27f blue:0.20f alpha:0.8f];
            break;
        case KDJ_FLAG_J:
            return [UIColor colorWithRed:0.8f green:0.68f blue:0.36f alpha:0.8f];
            break;
        default:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
    }
}

- (UIColor *)getColorByRSIFlag:(RSI_FLAG)flag
{
    switch (flag) {
        case RSI_FLAG_6:
            return [UIColor colorWithRed:0.18f green:0.69f blue:0.19f alpha:0.8f];
            break;
        case RSI_FLAG_12:
            return [UIColor colorWithRed:0.94f green:0.27f blue:0.20f alpha:0.8f];
            break;
        case RSI_FLAG_24:
            return [UIColor colorWithRed:0.8f green:0.68f blue:0.36f alpha:0.8f];
            break;
        default:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
    }
}

- (UIColor *)getColorByCanleData:(HJCandleChartModel *)candleModel
{
    if (candleModel.openPrice > candleModel.closePrice) {
        return [self getColorByStockFlag:STOCK_FLAG_DOWN];
    }else if (candleModel.openPrice < candleModel.closePrice) {
        return [self getColorByStockFlag:STOCK_FLAG_UP];
    }else {
        return [self getColorByStockFlag:STOCK_FLAG_DEFAULT];
    }
}

- (STOCK_FLAG)getStockFlagByCanleData:(HJCandleChartModel *)candleModel
{
    if (candleModel.openPrice > candleModel.closePrice) {
        return STOCK_FLAG_DOWN;
    }else if (candleModel.openPrice < candleModel.closePrice) {
        return STOCK_FLAG_UP;
    }else {
        return STOCK_FLAG_DEFAULT;
    }
}

- (NSString *)getStringByFlag:(STOCK_FLAG)flag
{
    switch (flag) {
        case STOCK_FLAG_MA5:
            return @"ma5";
            break;
        case STOCK_FLAG_MA10:
            return @"ma10";
            break;
        case STOCK_FLAG_MA30:
            return @"ma30";
            break;
        case STOCK_FLAG_MA60:
            return @"ma60";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)transformToUnitWithVolume:(long)volume
{
    return [self transformToUnitWithVolume:volume unitNum:100000000.0f];
}

- (NSString *)transformToUnitWithVolume:(long)volume unitNum:(float)unitNum
{
    int unitCount = volume/unitNum;
    
    if (unitNum == 1000.0f) {
        return [NSString stringWithFormat:@"%ld%@",volume,[self getUnitNameByNumber:unitNum]];
    }else {
        if (unitCount > 0) {
            return [NSString stringWithFormat:@"%.2f%@",volume/unitNum,[self getUnitNameByNumber:unitNum]];
        }else {
            return [self transformToUnitWithVolume:volume unitNum:unitNum/10];
        }
    }
}

- (NSString *)getUnitNameByNumber:(float)unitNum
{
    if (unitNum == 100000000.0f) {
        return @",亿";
    }else if (unitNum == 10000000.0f) {
        return @",千万";
    }else if (unitNum == 1000000.0f) {
        return @",百万";
    }else if (unitNum == 100000.0f) {
        return @",十万";
    }else if (unitNum == 10000.0f) {
        return @",万";
    }else{
        return @"";
    }
}

- (NSArray *)getMAArrayByFlag:(STOCK_FLAG)flag
{
    NSArray *maArr = nil;
    
    switch (flag) {
        case STOCK_FLAG_MA5:
        {
            maArr = self.curMA5Array;
        }
            break;
        case STOCK_FLAG_MA10:
        {
            maArr = self.curMA10Array;
        }
            break;
        case STOCK_FLAG_MA30:
        {
            maArr = self.curMA30Array;
        }
            break;
        case STOCK_FLAG_MA60:
        {
            maArr = self.curMA60Array;
        }
            break;
        default:
            break;
    }
    
    return maArr;
}

- (NSArray *)getKDJArrayByFlag:(KDJ_FLAG)flag
{
    NSArray *kdjArr = nil;
    
    switch (flag) {
        case KDJ_FLAG_K:
        {
            kdjArr = self.curKArray;
        }
            break;
        case KDJ_FLAG_D:
        {
            kdjArr = self.curDArray;
        }
            break;
        case KDJ_FLAG_J:
        {
            kdjArr = self.curJArray;
        }
            break;
        default:
            break;
    }
    
    return kdjArr;
}

- (NSArray *)getRSIArrayByFlag:(RSI_FLAG)flag
{
    NSArray *rsiArr = nil;
    
    switch (flag) {
        case RSI_FLAG_6:
        {
            rsiArr = self.curRSI6Array;
        }
            break;
        case RSI_FLAG_12:
        {
            rsiArr = self.curRSI12Array;
        }
            break;
        case RSI_FLAG_24:
        {
            rsiArr = self.curRSI24Array;
        }
            break;
        default:
            break;
    }
    
    return rsiArr;
}

@end
