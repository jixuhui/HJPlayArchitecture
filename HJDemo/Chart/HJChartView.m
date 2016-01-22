//
//  HJChartView.m
//  HJDemo
//
//  Created by jixuhui on 16/1/14.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "HJChartView.h"
#import "HJCandleChartModel.h"

typedef enum _STOCK_FLAG {
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
@property (nonatomic) long maxVolume;
@property (nonatomic) float volumeMaxViewHeight;
@property (nonatomic) float volumeHScale;
@property (nonatomic) long curIndex;
@property (nonatomic) float curBeginTouchPointX;

@property (nonatomic,strong) NSDictionary *chartLineData;
@property (nonatomic,strong) NSArray *curMA5Array;
@property (nonatomic,strong) NSArray *curMA10Array;
@property (nonatomic,strong) NSArray *curMA30Array;
@property (nonatomic,strong) NSArray *curMA60Array;

@end

@implementation HJChartView

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initChart];
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

- (void)initChart
{
    self.pricePaddingLeft = 50;
    self.pricePaddingRight = 10;
    self.pricePaddingTop = 90;
    self.pricePaddingDown = 120;
    
    self.volumePaddingTop = 20;
    self.volumePaddingDown = 40;
    
    self.volumeMaxViewHeight = self.pricePaddingDown - self.volumePaddingDown - self.volumePaddingTop;
    
    self.rangeSize = 37;
    self.rangeFrom = -1;
    
    self.yAlixsScale = 0;
    
    self.candleGap = 2;
    
    self.curIndex = -1;
    
    self.curBeginTouchPointX = -1;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)setModelsArray:(NSArray *)modelsArray
{
    _modelsArray = modelsArray;
    self.chartLineData = [self transformChartLineData];
    self.candleW = (CGRectGetWidth(self.bounds) - self.pricePaddingLeft - self.pricePaddingRight - self.candleGap * self.rangeSize)/self.rangeSize;
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
    
    NSString *maxHighPrice = [NSString stringWithFormat:@"%f",[self getHighPriceFromCurRange]];
    NSString *minLowPrice = [NSString stringWithFormat:@"%f",[self getLowPriceFromCurRange]];
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
    
    self.yAlixsScale = (CGRectGetHeight(self.bounds) - self.pricePaddingDown - self.pricePaddingTop)/(self.maxPrice - self.minPrice);
    
    //volume
    self.maxVolume = [self getMaxVolumeFromCurRange];
    self.volumeHScale = self.volumeMaxViewHeight/self.maxVolume;
}

- (void)renderMe
{
    [self reCaculateChartData];
    [self setNeedsDisplay];
}

#pragma mark - draw methods

- (void)drawRect:(CGRect)rect
{
    [self drawClearChart];
    if (CHECK_VALID_ARRAY(self.modelsArray)) {
        [self drawBackgroundDashLines];
        [self drawYAxis];
        //    [self drawXAxis];
        [self drawVolumeTips];
        [self drawCandleVeiwsAndVolumeViews];
        [self drawMAWithFlag:STOCK_FLAG_MA5];
        [self drawMAWithFlag:STOCK_FLAG_MA10];
        [self drawMAWithFlag:STOCK_FLAG_MA30];
        [self drawMAWithFlag:STOCK_FLAG_MA60];
        [self drawTopInfoView];
        [self drawIndexLineWithIndex:self.curIndex];
    }
}

- (void)drawClearChart
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
}

- (void)drawTopInfoView
{
    float labelTop = self.pricePaddingTop - 20;
    float labelW = 50;
    float labelH = 10;
    float labelGap = 5;
    float curLabelLeft = 0;
    
    long index = self.curIndex==-1?[self.curDrawModesArray count]-1:self.curIndex;//如果是第一次
    
    HJCandleChartModel *candleModel = (HJCandleChartModel *)[self.curDrawModesArray objectAtIndex:index];
    [[candleModel date] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
    
    curLabelLeft += labelW+labelGap;
    
    [[NSString stringWithFormat:@"MA5:%.2f",[[self.curMA5Array objectAtIndex:index+1] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA5]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA10:%.2f",[[self.curMA10Array objectAtIndex:index+1] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA10]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA30:%.2f",[[self.curMA30Array objectAtIndex:index+1] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA30]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA60:%.2f",[[self.curMA60Array objectAtIndex:index+1] floatValue]] drawInRect:CGRectMake(curLabelLeft, labelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA60]];
}

- (void)drawBackgroundDashLines
{
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.maxPrice]];
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.averagePrice]];
    
    [self drawDashLinesWithYPoint:[self transformVolumeToYPoint:self.maxVolume]];
    [self drawDashLinesWithYPoint:[self transformVolumeToYPoint:self.maxVolume/2]];
    
    [self drawMoreChartInfoYAxisAndXAxis];
}

- (void)drawDashLinesWithYPoint:(float)pointY
{
    CGFloat length[] = {10,5};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 2);
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.pricePaddingLeft, pointY);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.pricePaddingRight, pointY);
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, NULL, 0);//必须加，为了保证不影响其他样式的绘制
}

- (void)drawSolidLineWithYPoint:(float)pointY
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.pricePaddingLeft, pointY);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.pricePaddingRight, pointY);
    CGContextStrokePath(context);
}

- (void)drawIndexLineWithIndex:(long)index
{
    if (index<0) {
        return;
    }
    
    float pointX = self.pricePaddingLeft + index*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, pointX, self.pricePaddingTop);
    CGContextAddLineToPoint(context, pointX, CGRectGetHeight(self.bounds)-self.volumePaddingDown);
    CGContextStrokePath(context);
}

- (void)drawMoreChartInfoYAxisAndXAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.pricePaddingLeft, [self transformVolumeToYPoint:self.maxVolume]);
    CGContextAddLineToPoint(context, self.pricePaddingLeft, [self transformVolumeToYPoint:0]);
    CGContextStrokePath(context);
    
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, self.pricePaddingLeft, [self transformVolumeToYPoint:0]+1);
//    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.pricePaddingRight, [self transformVolumeToYPoint:0]+1);
//    CGContextStrokePath(context);
}

- (void)drawYAxis
{
    //绘制纵轴
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.pricePaddingLeft, self.pricePaddingTop);
    CGContextAddLineToPoint(context, self.pricePaddingLeft, CGRectGetHeight(self.bounds) - self.pricePaddingDown);
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
    
    [[NSString stringWithFormat:@"%.2f",self.maxPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.maxPrice] - labelH/2, self.pricePaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.averagePrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.averagePrice] - labelH/2, self.pricePaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.minPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.minPrice] - labelH/2, self.pricePaddingLeft-2, labelH) withAttributes:attributes];
}

- (void)drawXAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.pricePaddingLeft, CGRectGetHeight(self.bounds) - self.pricePaddingDown);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.pricePaddingRight, CGRectGetHeight(self.bounds) - self.pricePaddingDown);
    CGContextStrokePath(context);
}

- (void)drawCandleVeiwsAndVolumeViews
{
    int i = 0;
    for (HJCandleChartModel *candle in self.curDrawModesArray) {
        
        float pointX = self.pricePaddingLeft + i*(self.candleGap + self.candleW) + self.candleGap;
        float linePX = pointX + self.candleW/2;
        
        float openPricePoint = [self transformPriceToYPoint:candle.openPrice];
        float closePricePoint = [self transformPriceToYPoint:candle.closePrice];
        float highPricePoint = [self transformPriceToYPoint:candle.highPrice];
        float lowPricePoint = [self transformPriceToYPoint:candle.lowPrice];
        
        STOCK_FLAG flag = STOCK_FLAG_DEFAULT;
        
        if (openPricePoint < closePricePoint) {
            flag = STOCK_FLAG_DOWN;
            
            //跌了 先绘制蜡烛
            [self drawCandleWithPointA:openPricePoint pointB:closePricePoint pointX:pointX flag:flag];
            
            //绘制上影线
            if (highPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:highPricePoint linePX:linePX flag:flag];
            }
            
            //绘制下影线
            if (lowPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:lowPricePoint linePX:linePX flag:flag];
            }
        }else {
            flag = STOCK_FLAG_UP;
            
            [self drawCandleWithPointA:openPricePoint pointB:closePricePoint pointX:pointX flag:flag];
            
            if (highPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:highPricePoint linePX:linePX flag:flag];
            }
            
            if (lowPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:lowPricePoint linePX:linePX flag:flag];
            }
        }
        
        float volumePoint = [self transformVolumeToYPoint:candle.volume];
        [self drawVolumeWithPoint:volumePoint pointX:pointX flag:flag];
        
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

- (void)drawVolumeTips
{
    float labelH = 9;
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [[self transformToUnitWithVolume:self.maxVolume] drawInRect:CGRectMake(0, [self transformVolumeToYPoint:self.maxVolume] - labelH/2, self.pricePaddingLeft-2, labelH) withAttributes:attributes];
    
    [@"0" drawInRect:CGRectMake(0, [self transformVolumeToYPoint:0] - labelH/2, self.pricePaddingLeft-2, labelH) withAttributes:attributes];
}

- (void)drawVolumeWithPoint:(float)volumeYPoint pointX:(float)pointX flag:(STOCK_FLAG)flag
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rectangle = CGRectMake(pointX, volumeYPoint, self.candleW, CGRectGetHeight(self.bounds) - volumeYPoint - self.volumePaddingDown);
    CGPathAddRect(path, NULL, rectangle);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);
    [[self getColorByFlag:flag] setFill];
    [[self getColorByFlag:flag] setStroke];
    CGContextSetLineWidth(currentContext, 0.5f);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    CGPathRelease(path);
}

- (void)drawMAWithFlag:(STOCK_FLAG)flag
{
    NSArray *maArr = [self getMAArrayByFlag:flag];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self getColorByFlag:flag] setStroke];
    CGContextBeginPath(context);
    
    for (int i=0; i<[maArr count]; i++) {
        float maValue = [[maArr objectAtIndex:i] floatValue];
        float pointX = self.pricePaddingLeft;
        
        if (i==0) {
            CGContextMoveToPoint(context, pointX, [self transformPriceToYPoint:maValue]);
        }else {
            pointX = self.pricePaddingLeft + (i-1)*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
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

- (float)getHighPriceFromCurRange
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

- (float)getLowPriceFromCurRange
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

- (float)transformPriceToYPoint:(float)priceValue
{
    return CGRectGetHeight(self.bounds) - (priceValue - self.minPrice)*self.yAlixsScale - self.pricePaddingDown;
}

- (float)transformVolumeToYPoint:(long)volume
{
    return CGRectGetHeight(self.bounds) - volume*self.volumeHScale - self.volumePaddingDown;
}

- (NSDictionary *)getTopInfoAttributesByFlag:(STOCK_FLAG)flag
{
    UIFont *font = [UIFont systemFontOfSize:7];
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

- (NSString *)getUnitNameByNumber:(float)unitNum
{
    if (unitNum == 100000000.0f) {
        return @"(亿)";
    }else if (unitNum == 10000000.0f) {
        return @"(千万)";
    }else if (unitNum == 1000000.0f) {
        return @"(百万)";
    }else if (unitNum == 100000.0f) {
        return @"(十万)";
    }else if (unitNum == 10000.0f) {
        return @"(万)";
    }else{
        return @"";
    }
}

- (long)getIndexByPointX:(float)pointX
{
    if (pointX>=CGRectGetWidth(self.bounds)-self.pricePaddingRight) {
        return [self.curDrawModesArray count]-1;
    }else if(pointX<=self.pricePaddingLeft) {
        return 0;
    }else {
        return (pointX - self.pricePaddingLeft)/(self.candleW + self.candleGap);
    }
}

#pragma mark - touch event

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    
    self.curIndex = [self getIndexByPointX:point.x];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){

    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        self.curIndex = -1;
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
    }
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *ts = [touches allObjects];
    if([ts count]==1) {
        UITouch* touch = ts[0];
        float touchPointX = [touch locationInView:self].x;
        float touchPointY = [touch locationInView:self].y;
        
        if(touchPointX > self.pricePaddingLeft && touchPointX < CGRectGetWidth(self.bounds) - self.pricePaddingRight && touchPointY < CGRectGetHeight(self.bounds) - self.pricePaddingDown && touchPointY > self.pricePaddingTop){
            self.curBeginTouchPointX = touchPointX;
        }
    }else if ([ts count]==2) {
//        self.touchFlag = [ts[0] locationInView:self].x;
//        self.touchFlagTwo = [ts[1] locationInView:self].x;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *ts = [touches allObjects];
    if([ts count]==1) {
        
        if (self.curBeginTouchPointX != -1) {
            
            UITouch* touch = ts[0];
            float touchPointX = [touch locationInView:self].x;
            float touchChg = touchPointX - self.curBeginTouchPointX;
            
            int indexChg = fabs(touchChg)/(self.candleGap + self.candleW);
            
            if (indexChg > 0) {
                if (touchChg>0) {
                    if (self.rangeFrom == 0) {
                        return;
                    }else if (self.rangeFrom -indexChg < 0) {
                        self.rangeFrom = 0;
                    }else {
                        self.rangeFrom -= indexChg;
                    }
                }else {
                    if (self.rangeFrom + self.rangeSize == [self.modelsArray count]-1) {
                        return;
                    }else if (self.rangeFrom + self.rangeSize + indexChg > [self.modelsArray count] - 1) {
                        self.rangeFrom = [self.modelsArray count] - self.rangeSize;
                    }else {
                        self.rangeFrom += indexChg;
                    }
                }
                self.curBeginTouchPointX = touchPointX;
                [self renderMe];
            }
        }
    }else if ([ts count]==2) {
//        float currFlag = [ts[0] locationInView:self].x;
//        float currFlagTwo = [ts[1] locationInView:self].x;
        
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSArray *ts = [touches allObjects];
//    UITouch* touch = [[event allTouches] anyObject];
//    if([ts count]==1){
//        int i = [self getIndexOfSection:[touch locationInView:self]];
//        if(i!=-1){
//            Section *sec = self.sections[i];
//            if([touch locationInView:self].x > sec.paddingLeft){
//                if(sec.paging){
//                    [sec nextPage];
//                    [self setNeedsDisplay];
//                }else{
//                    [self setSelectedIndexByPoint:[touch locationInView:self]];
//                }
//            }
//        }
//    }
//    self.touchFlag = 0;
//}

@end
