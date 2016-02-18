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
    
    self.curMA5Array = [(NSArray *)[self.chartLineData dataForKey:@"ma5"] objectsAtIndexes:se];
    self.curMA10Array = [(NSArray *)[self.chartLineData dataForKey:@"ma10"] objectsAtIndexes:se];
    self.curMA30Array = [(NSArray *)[self.chartLineData dataForKey:@"ma30"] objectsAtIndexes:se];
    self.curMA60Array = [(NSArray *)[self.chartLineData dataForKey:@"ma60"] objectsAtIndexes:se];
    
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
    self.curKArray = [(NSArray *)[self.chartLineData dataForKey:@"kdj_k"] objectsAtIndexes:se];
    self.curDArray = [(NSArray *)[self.chartLineData dataForKey:@"kdj_d"] objectsAtIndexes:se];
    self.curJArray = [(NSArray *)[self.chartLineData dataForKey:@"kdj_j"] objectsAtIndexes:se];
    
    NSDictionary *kDic = [self getMaxAndMinFromArray:self.curKArray];
    NSDictionary *dDic = [self getMaxAndMinFromArray:self.curDArray];
    NSDictionary *jDic = [self getMaxAndMinFromArray:self.curJArray];
    NSArray *maxKDJArr = @[kDic[@"max"],dDic[@"max"],jDic[@"max"]];
    NSArray *minKDJArr = @[kDic[@"min"],dDic[@"min"],jDic[@"min"]];
   
    self.maxKDJValue = [self getMaxFromArray:maxKDJArr];
    self.minKDJValue = [self getMinFromArray:minKDJArr];
    
    //rsi
    self.curRSI6Array = [(NSArray *)[self.chartLineData dataForKey:@"rsi6"] objectsAtIndexes:se];
    self.curRSI12Array = [(NSArray *)[self.chartLineData dataForKey:@"rsi12"] objectsAtIndexes:se];
    self.curRSI24Array = [(NSArray *)[self.chartLineData dataForKey:@"rsi24"] objectsAtIndexes:se];
    
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"volume>0"];
    _modelsArray = [modelsArray filteredArrayUsingPredicate:predicate];
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
    [dic setValuesForKeysWithDictionary:[self calculateRSI]];
    
    //KDJ
    [dic setValuesForKeysWithDictionary:[self calculateKDJ]];
    
    return dic;
}

- (NSArray *)calculateMAWithDays:(int)dayNum
{
    NSMutableArray *maArray = [[NSMutableArray alloc] init];
    for(int i = 0;i < self.modelsArray.count;i++){
        float val = 0;
        
        int dayCount = i + 1;
        if (i>=dayNum-1) {
            dayCount = dayNum;
        }
        
        for(int j=i;j>i-dayCount;j--){
            HJCandleChartModel *chartModel = self.modelsArray[j];
            val += chartModel.closePrice;
        }
        
        val = val/dayCount;
        [maArray addObject:[@"" stringByAppendingFormat:@"%.3f",val]];
    }
    
    return maArray;
}

- (NSDictionary *)calculateRSI
{
    if (!CHECK_VALID_ARRAY(self.modelsArray)) {
        return nil;
    }
    
    long len = [self.modelsArray count];
    
    int e1 = 6;
    int e2 = 12;
    int e3 = 24;
    
    float sum1,sum2,sum3,sum4,sum5,sum6;
    float c,max,abs;
    
    typedef struct _MA
    {
        float ma1;
        float ma2;
        float ma3;
        float ma4;
        float ma5;
        float ma6;
    }MA;
    
    float *maxArr = malloc(sizeof(float)*len);
    float *absArr = malloc(sizeof(float)*len);
    MA *maArr = malloc(sizeof(MA)*len);
    
    NSMutableArray *rsi6Arr = [[NSMutableArray alloc] init];
    NSMutableArray *rsi12Arr = [[NSMutableArray alloc] init];
    NSMutableArray *rsi24Arr = [[NSMutableArray alloc] init];
    
    HJCandleChartModel *item = [self.modelsArray firstObject];
    float oldclose = item.closePrice;
    float oldopen = item.openPrice;
    
    float firstClose = 0.0f;
    if (firstClose<=0.0000001f) {
        firstClose = oldopen;
    }
    if(firstClose<=0.0000001f || firstClose<0)
    {
        sum1 = sum2 = sum3 = sum4 = sum5 = sum6 = max = abs = oldclose*.1;
    }else
    {
        c=oldclose-firstClose;
        sum1 = sum2 = sum3 = max =MAX(c, 0);
        sum4 = sum5 = sum6 = abs =fabsf(c);
    }
    MA ma;
    ma.ma1 = max;
    ma.ma2 = max;
    ma.ma3 = max;
    ma.ma4 = abs;
    ma.ma5 = abs;
    ma.ma6 = abs;
    
    maxArr[0]=max;
    absArr[0]=abs;
    maArr[0]=ma;
    
    float preClose = oldclose;
    MA prema = ma;
    for(int i=1;i<len;i++){
        item = [self.modelsArray objectAtIndex:i];
        oldclose = item.closePrice;
        c=oldclose-preClose;
        preClose = oldclose;
        max=MAX(c,0);
        abs=fabsf(c);
        maxArr[i]=max;
        absArr[i]=abs;
        
        sum1+=max;
        if(i>=e1){
            sum1=max+prema.ma1*(e1-1);
            ma.ma1=sum1/e1;
        }else	ma.ma1=sum1/(i+1);
        
        sum2+=max;
        if(i>=e2){
            sum2=max+prema.ma2*(e2-1);
            ma.ma2=sum2/e2;
        }else	ma.ma2=sum2/(i+1);
        
        sum3+=max;
        if(i>=e3){
            sum3=max+prema.ma3*(e3-1);
            ma.ma3=sum3/e3;
        }else	ma.ma3=sum3/(i+1);
        
        sum4+=abs;
        if(i>=e1){
            sum4=abs+prema.ma4*(e1-1);
            ma.ma4=sum4/e1;
        }else	ma.ma4=sum4/(i+1);
        
        sum5+=abs;
        if(i>=e2){
            sum5=abs+prema.ma5*(e2-1);
            ma.ma5=sum5/e2;
        }else	ma.ma5=sum5/(i+1);
        
        sum6+=abs;
        if(i>=e3){
            sum6=abs+prema.ma6*(e3-1);
            ma.ma6=sum6/e3;
        }else	ma.ma6=sum6/(i+1);
        
        maArr[i] = ma;
        prema = ma;
    }
    
    for(int i=0;i<len;i++){
        ma=maArr[i];
        float preris6 = [rsi6Arr count]>i?[[rsi6Arr objectAtIndex:i] floatValue]:-1;
        float preris12 = [rsi12Arr count]>i?[[rsi12Arr objectAtIndex:i] floatValue]:-1;
        float preris24 = [rsi24Arr count]>i?[[rsi24Arr objectAtIndex:i] floatValue]:-1;
        
        float rsi6 = ma.ma4>0?(ma.ma1/ma.ma4)*100:preris6;
        float rsi12 = ma.ma5>0?(ma.ma2/ma.ma5)*100:preris12;
        float rsi24 = ma.ma6>0?(ma.ma3/ma.ma6)*100:preris24;
        
        [rsi6Arr addObject:[NSString stringWithFormat:@"%.3f",rsi6]];
        [rsi12Arr addObject:[NSString stringWithFormat:@"%.3f",rsi12]];
        [rsi24Arr addObject:[NSString stringWithFormat:@"%.3f",rsi24]];
    }
    
    free(maxArr);
    free(absArr);
    free(maArr);
    
    return @{@"rsi6":rsi6Arr,@"rsi12":rsi12Arr,@"rsi24":rsi24Arr};
}

- (NSDictionary *)calculateKDJ
{
    NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
    NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
    NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
    float rsv = 0;
    
    int ek = 3;
    int ed = 3;
    int em = 9;
    float defaultLTK = 17.0f;
    
    float k = -1;
    float d = -1;
    float j = -1;
    
    HJCandleChartModel *firstModel = [self.modelsArray firstObject];
    
    if (firstModel.lowPrice==firstModel.highPrice) {
        k = defaultLTK;
    }
    else
    {
        k = (firstModel.closePrice-firstModel.lowPrice)/(firstModel.highPrice-firstModel.lowPrice)*100/ek;
    }
    d = k/ed;
    j = 3*k-2*d;
    
    [kdj_k addObject:[@"" stringByAppendingFormat:@"%.3f",k]];
    [kdj_d addObject:[@"" stringByAppendingFormat:@"%.3f",d]];
    [kdj_j addObject:[@"" stringByAppendingFormat:@"%.3f",j]];
    
    float prev_k = k;
    float prev_d = d;
    
    for(int i = 1;i < self.modelsArray.count;i++){
        
        int index = 0;
        int num = i+1;
        if (i>=em) {
            index = i - em + 1;
            num = em;
        }
        
        NSIndexSet *se = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, num)];
        NSArray *curArray = [self.modelsArray objectsAtIndexes:se];
        
        float h = [self getHighPriceFromCandleArray:curArray];
        float l = [self getLowPriceFromCandleArray:curArray];
        float c = [[curArray lastObject] closePrice];
        
        if(h==l){
            k = defaultLTK;
        }else {
            rsv = (c-l)/(h-l)*100;
            k = (ek-1)*prev_k/ek+rsv/ek;
        }
        
        d = (ed-1)*prev_d/ed+k/ed;
        j = 3*k-2*d;
        
        prev_k = k;
        prev_d = d;
        
        [kdj_k addObject:[@"" stringByAppendingFormat:@"%.3f",k]];
        [kdj_d addObject:[@"" stringByAppendingFormat:@"%.3f",d]];
        [kdj_j addObject:[@"" stringByAppendingFormat:@"%.3f",j]];
    }
    
    return @{@"kdj_k":kdj_k,@"kdj_d":kdj_d,@"kdj_j":kdj_j};
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
