//
//  HJChartView.m
//  HJDemo
//
//  Created by jixuhui on 16/1/14.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "HJChartView.h"
#import "HJCandleChartModel.h"

typedef enum _STOCK_FLAG
{
    STOCK_FLAG_UP = 0,
    STOCK_FLAG_DOWN,
    STOCK_FLAG_MA5,
    STOCK_FLAG_MA10,
    STOCK_FLAG_MA30,
    STOCK_FLAG_MA60,
    STOCK_FLAG_DEFAULT
}STOCK_FLAG;

@interface HJChartView()

@property (nonatomic) float yAlixsScale;
@property (nonatomic) float maxPrice;
@property (nonatomic) float minPrice;
@property (nonatomic) float averagePrice;
@property (nonatomic) float candleGap;
@property (nonatomic) float candleW;

@property (nonatomic,strong) NSDictionary *chartLineData;

@end

@implementation HJChartView

#pragma mark - life cycle

- (instancetype)initWithData:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.modelsArray = array;
        
        self.paddingLeft = 30;
        self.paddingRight = 10;
        self.paddingTop = 50;
        self.paddingDown = 120;
        
        self.rangeSize = 37;
        self.rangeFrom = [self.modelsArray count] - self.rangeSize;
        
        self.yAlixsScale = 0;
        
        self.candleGap = 2;
    }
    return self;
}

- (void)initChart
{
    self.chartLineData = [self transformChartLineData];
    
    NSIndexSet *se = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rangeFrom, self.rangeSize)];
    self.curDrawModesArray = [self.modelsArray objectsAtIndexes:se];
    
    self.maxPrice = [self getHighPriceModelFromCurRange];
    self.minPrice = [self getLowPriceModelFromCurRange];
    self.averagePrice = (self.maxPrice + self.minPrice)/2;
    self.yAlixsScale = (CGRectGetHeight(self.bounds) - self.paddingDown - self.paddingTop)/(self.maxPrice - self.minPrice);
    self.candleW = (CGRectGetWidth(self.bounds) - self.paddingLeft - self.paddingRight - self.candleGap * self.rangeSize)/self.rangeSize;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height));
}

#pragma mark - draw methods

- (void)drawRect:(CGRect)rect
{
    [self initChart];
    [self drawTopInfoView];
    [self drawYAxis];
    [self drawXAxis];
    [self drawCandleVeiws];
    [self drawMAWithFlag:STOCK_FLAG_MA5];
    [self drawMAWithFlag:STOCK_FLAG_MA10];
    [self drawMAWithFlag:STOCK_FLAG_MA30];
//    [self drawMAWithFlag:STOCK_FLAG_MA60];
}

- (void)drawTopInfoView
{
    float labelTop = self.paddingTop - 20;
    float labelW = 50;
    float labelH = 10;
    float labelGap = 5;
    float curLabelLeft = 0;
    
    HJCandleChartModel *candleModel = (HJCandleChartModel *)[self.curDrawModesArray lastObject];
    [[candleModel date] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
    
    NSArray *ma5Arr = (NSArray *)[self.chartLineData dataForKey:@"ma5"];
    NSArray *ma10Arr = (NSArray *)[self.chartLineData dataForKey:@"ma10"];
    NSArray *ma30Arr = (NSArray *)[self.chartLineData dataForKey:@"ma30"];
//    NSArray *ma60Arr = (NSArray *)[self.chartLineData dataForKey:@"ma60"];
    
    curLabelLeft += labelW+labelGap;
    
    [[NSString stringWithFormat:@"MA5:%.2f",[[ma5Arr lastObject] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA5]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA10:%.2f",[[ma10Arr lastObject] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA10]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA30:%.2f",[[ma30Arr lastObject] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA30]];
    
//    curLabelLeft += labelW + labelGap;
//    
//    [[NSString stringWithFormat:@"MA60:%.2f",[[ma60Arr lastObject] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA60]];
}

- (void)drawYAxis
{
    //绘制纵轴
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.paddingLeft, self.paddingTop);
    CGContextAddLineToPoint(context, self.paddingLeft, CGRectGetHeight(self.bounds) - self.paddingDown);
    CGContextStrokePath(context);
    
    //绘制纵坐标值
    float labelH = 9;
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [[NSString stringWithFormat:@"%.2f",self.maxPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.maxPrice] - labelH/2, self.paddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.averagePrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.averagePrice] - labelH/2, self.paddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.minPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.minPrice] - labelH/2, self.paddingLeft-2, labelH) withAttributes:attributes];
}

- (void)drawXAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.paddingLeft, CGRectGetHeight(self.bounds) - self.paddingDown);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.paddingRight, CGRectGetHeight(self.bounds) - self.paddingDown);
    CGContextStrokePath(context);
}

- (void)drawCandleVeiws
{
    int i = 0;
    for (HJCandleChartModel *candle in self.curDrawModesArray) {
        
        float pointX = self.paddingLeft + i*(self.candleGap + self.candleW) + self.candleGap;
        float linePX = pointX + self.candleW/2;
        
        float openPricePoint = [self transformPriceToYPoint:candle.openPrice];
        float closePricePoint = [self transformPriceToYPoint:candle.closePrice];
        float highPricePoint = [self transformPriceToYPoint:candle.highPrice];
        float lowPricePoint = [self transformPriceToYPoint:candle.lowPrice];
        
        if (openPricePoint < closePricePoint) {
            //跌了 先绘制蜡烛
            [self drawCandleWithPointA:openPricePoint pointB:closePricePoint pointX:pointX flag:STOCK_FLAG_DOWN];
            
            //绘制上影线
            if (highPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:highPricePoint linePX:linePX flag:STOCK_FLAG_DOWN];
            }
            
            //绘制下影线
            if (lowPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:lowPricePoint linePX:linePX flag:STOCK_FLAG_DOWN];
            }
        }else {
            [self drawCandleWithPointA:openPricePoint pointB:closePricePoint pointX:pointX flag:STOCK_FLAG_UP];
            
            if (highPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:highPricePoint linePX:linePX flag:STOCK_FLAG_UP];
            }
            
            if (lowPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:lowPricePoint linePX:linePX flag:STOCK_FLAG_UP];
            }
        }
        
        i ++;
    }
}

- (void)drawCandleWithPointA:(float)pointA pointB:(float)pointB pointX:(float)pointX flag:(STOCK_FLAG)flag
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rectangle = CGRectMake(pointX, MIN(pointA, pointB), self.candleW, fabs(pointA - pointB));
    CGPathAddRect(path, NULL, rectangle);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);
    [[self getColorByFlag:flag] setFill];
    [[self getColorByFlag:flag] setStroke];
    CGContextSetLineWidth(currentContext, 0.5f);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    CGPathRelease(path);
}

- (void)drawHatchWithPointA:(float)pointA pointB:(float)pointB linePX:(float)linePX flag:(STOCK_FLAG)flag
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self getColorByFlag:flag] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, linePX, pointA);
    CGContextAddLineToPoint(context, linePX, pointB);
    CGContextStrokePath(context);
}

- (void)drawMAWithFlag:(STOCK_FLAG)flag
{
    NSIndexSet *se = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rangeFrom-1, self.rangeSize+1)];
    
    NSArray *maArr = [(NSArray *)[self.chartLineData dataForKey:[self getStringByFlag:flag]] objectsAtIndexes:se];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self getColorByFlag:flag] setStroke];
    CGContextBeginPath(context);
    
    for (int i=0; i<[maArr count]; i++) {
        float maValue = [[maArr objectAtIndex:i] floatValue];
        float pointX = self.paddingLeft;
        
        if (i==0) {
            CGContextMoveToPoint(context, pointX, [self transformPriceToYPoint:maValue]);
        }else {
            pointX = self.paddingLeft + (i-1)*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
            CGContextAddLineToPoint(context, pointX, [self transformPriceToYPoint:maValue]);
        }
    }
    
    CGContextStrokePath(context);
}

#pragma mark - help methods

/**
 *  @author Hubbert, 16-01-19 13:01:08
 *
 *  @brief 基础数据转技术曲线数据
 *
 *  @return
 *
 *  @since 1.0
 */

- (NSDictionary *)transformChartLineData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    
//    //price
//    NSMutableArray *price = [[NSMutableArray alloc] init];
//    for(int i = 60;i < data.count;i++){
//        [price addObject:data[i]];
//    }
//    dic[@"price"] = price;
//    
//    //VOL
//    NSMutableArray *vol = [[NSMutableArray alloc] init];
//    for(int i = 60;i < data.count;i++){
//        NSMutableArray *item = [[NSMutableArray alloc] init];
//        [item addObject:[@"" stringByAppendingFormat:@"%f",[[data[i] objectAtIndex:4] floatValue]/100]];
//        [vol addObject:item];
//    }
//    dic[@"vol"] = vol;
    
    //MA
    dic[@"ma5"] = [self calculateMAWithDays:@"5"];
    dic[@"ma10"] = [self calculateMAWithDays:@"10"];
    dic[@"ma30"] = [self calculateMAWithDays:@"30"];
    dic[@"ma60"] = [self calculateMAWithDays:@"60"];
    
//    //RSI6
//    NSMutableArray *rsi6 = [[NSMutableArray alloc] init];
//    for(int i = 60;i < data.count;i++){
//        float incVal  = 0;
//        float decVal = 0;
//        float rs = 0;
//        for(int j=i;j>i-6;j--){
//            float interval = [[data[j] objectAtIndex:1] floatValue]-[[data[j] objectAtIndex:0] floatValue];
//            if(interval >= 0){
//                incVal += interval;
//            }else{
//                decVal -= interval;
//            }
//        }
//        
//        rs = incVal/decVal;
//        float rsi =100-100/(1+rs);
//        
//        NSMutableArray *item = [[NSMutableArray alloc] init];
//        [item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
//        [rsi6 addObject:item];
//        
//    }
//    dic[@"rsi6"] = rsi6;
//    
//    //RSI12
//    NSMutableArray *rsi12 = [[NSMutableArray alloc] init];
//    for(int i = 60;i < data.count;i++){
//        float incVal  = 0;
//        float decVal = 0;
//        float rs = 0;
//        for(int j=i;j>i-12;j--){
//            float interval = [[data[j] objectAtIndex:1] floatValue]-[[data[j] objectAtIndex:0] floatValue];
//            if(interval >= 0){
//                incVal += interval;
//            }else{
//                decVal -= interval;
//            }
//        }
//        
//        rs = incVal/decVal;
//        float rsi =100-100/(1+rs);
//        
//        NSMutableArray *item = [[NSMutableArray alloc] init];
//        [item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
//        [rsi12 addObject:item];
//    }
//    dic[@"rsi12"] = rsi12;
//    
//    //WR
//    NSMutableArray *wr = [[NSMutableArray alloc] init];
//    for(int i = 60;i < data.count;i++){
//        float h  = [[data[i] objectAtIndex:2] floatValue];
//        float l = [[data[i] objectAtIndex:3] floatValue];
//        float c = [[data[i] objectAtIndex:1] floatValue];
//        for(int j=i;j>i-10;j--){
//            if([[data[j] objectAtIndex:2] floatValue] > h){
//                h = [[data[j] objectAtIndex:2] floatValue];
//            }
//            
//            if([[data[j] objectAtIndex:3] floatValue] < l){
//                l = [[data[j] objectAtIndex:3] floatValue];
//            }
//        }
//        
//        float val = (h-c)/(h-l)*100;
//        NSMutableArray *item = [[NSMutableArray alloc] init];
//        [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
//        [wr addObject:item];
//    }
//    dic[@"wr"] = wr;
//    
//    //KDJ
//    NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
//    NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
//    NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
//    float prev_k = 50;
//    float prev_d = 50;
//    float rsv = 0;
//    for(int i = 60;i < data.count;i++){
//        float h  = [[data[i] objectAtIndex:2] floatValue];
//        float l = [[data[i] objectAtIndex:3] floatValue];
//        float c = [[data[i] objectAtIndex:1] floatValue];
//        for(int j=i;j>i-10;j--){
//            if([[data[j] objectAtIndex:2] floatValue] > h){
//                h = [[data[j] objectAtIndex:2] floatValue];
//            }
//            
//            if([[data[j] objectAtIndex:3] floatValue] < l){
//                l = [[data[j] objectAtIndex:3] floatValue];
//            }
//        }
//        
//        if(h!=l)
//            rsv = (c-l)/(h-l)*100;
//        float k = 2*prev_k/3+1*rsv/3;
//        float d = 2*prev_d/3+1*k/3;
//        float j = d+2*(d-k);
//        
//        prev_k = k;
//        prev_d = d;
//        
//        NSMutableArray *itemK = [[NSMutableArray alloc] init];
//        [itemK addObject:[@"" stringByAppendingFormat:@"%f",k]];
//        [kdj_k addObject:itemK];
//        NSMutableArray *itemD = [[NSMutableArray alloc] init];
//        [itemD addObject:[@"" stringByAppendingFormat:@"%f",d]];
//        [kdj_d addObject:itemD];
//        NSMutableArray *itemJ = [[NSMutableArray alloc] init];
//        [itemJ addObject:[@"" stringByAppendingFormat:@"%f",j]];
//        [kdj_j addObject:itemJ];
//    }
//    dic[@"kdj_k"] = kdj_k;
//    dic[@"kdj_d"] = kdj_d;
//    dic[@"kdj_j"] = kdj_j;
//    
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

- (NSArray *)calculateMAWithDays:(NSString *)dayStr
{
    int daysCount = [dayStr intValue];
    
    NSMutableArray *maArray = [[NSMutableArray alloc] init];
    for(int i = 0;i < self.modelsArray.count;i++){
        float val = 0;
        
        int minValue = i>=daysCount-1?i-(daysCount-1):0;
        
        for(int j=i;j>=minValue;j--){
            HJCandleChartModel *chartModel = self.modelsArray[j];
            val += chartModel.closePrice;
        }
        
        val = val/daysCount;
        [maArray addObject:[@"" stringByAppendingFormat:@"%f",val]];
    }
    
    return maArray;
}

- (float)getHighPriceModelFromCurRange
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
    
    NSArray *array = [self.curDrawModesArray sortedArrayUsingComparator:cmptr];
    HJCandleChartModel *highModel = [array lastObject];
    return highModel.highPrice;
}

- (float)getLowPriceModelFromCurRange
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
    
    NSArray *array = [self.curDrawModesArray sortedArrayUsingComparator:cmptr];
    HJCandleChartModel *lowModel = [array lastObject];
    return lowModel.lowPrice;
}

- (float)transformPriceToYPoint:(float)priceValue
{
    return CGRectGetHeight(self.bounds) - (priceValue - self.minPrice)*self.yAlixsScale - self.paddingDown;
}

- (NSDictionary *)getTopInfoAttributesByFlag:(STOCK_FLAG)flag
{
    UIFont *font = [UIFont systemFontOfSize:6];
    UIColor *color = [self getColorByFlag:flag];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    return attributes;
}

- (UIColor *)getColorByFlag:(STOCK_FLAG)flag
{
    switch (flag) {
        case STOCK_FLAG_DEFAULT:
            return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            break;
        case STOCK_FLAG_UP:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
        case STOCK_FLAG_DOWN:
            return [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
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
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
        default:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
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

@end
