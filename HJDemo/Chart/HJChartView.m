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
    STOCK_FLAG_DASH,
    STOCK_FLAG_DEFAULT
}STOCK_FLAG;

typedef enum _LONG_PRESS_FLAG {
    LONG_PRESS_FLAG_NONE = 0,
    LONG_PRESS_FLAG_INDEX,
    LONG_PRESS_FLAG_CHANGE_AREA
}LONG_PRESS_FLAG;

@interface HJChartView()

@property (nonatomic) long rangeFrom;
@property (nonatomic) long rangeSize;

//candleAreaPadding
@property (nonatomic) float candleAreaPaddingLeft;
@property (nonatomic) float candleAreaPaddingRight;
@property (nonatomic) float candleAreaPaddingTop;
@property (nonatomic) float candleAreaPaddingDown;
@property (nonatomic) float candleAreaMaxPaddingDown;
@property (nonatomic) float candleAreaMinPaddingDown;
//infoAreaPadding
//@property (nonatomic) float infoAreaPaddingTop;
@property (nonatomic) float infoAreaPaddingDown;
//infoArea vs candleArea Gap
@property (nonatomic) float candleWithInfoAreaGap;

@property (nonatomic) float yAlixsScale;
@property (nonatomic) float candleYAlixsToEdge;
@property (nonatomic) float maxPrice;
@property (nonatomic) float minPrice;
@property (nonatomic) float averagePrice;
@property (nonatomic) float candleGap;
@property (nonatomic) float candleW;
@property (nonatomic) float minCandleW;
@property (nonatomic) float maxCandleW;
@property (nonatomic) long maxVolume;
@property (nonatomic) float volumeMaxViewHeight;
@property (nonatomic) float volumeHScale;
@property (nonatomic) long curIndex;
@property (nonatomic) LONG_PRESS_FLAG longPressFlag;
@property (nonatomic) float curBeginLongPressPointY;
@property (nonatomic) float curBeginTouchPointX;
@property (nonatomic) float curBeginMutipleTouchPointXChange;

@property (nonatomic,strong) NSArray *curDrawModesArray;

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
    self.candleYAlixsToEdge = 20;
    
    self.candleAreaPaddingLeft = 50;
    self.candleAreaPaddingRight = 10;
    self.candleAreaPaddingTop = 90;
    self.candleAreaPaddingDown = 120;
    self.candleAreaMaxPaddingDown = 200;
    self.candleAreaMinPaddingDown = 80;
    
    self.candleWithInfoAreaGap = 20;
    self.infoAreaPaddingDown = 40;
    
    self.rangeSize = 80;
    self.rangeFrom = -1;
    
    self.yAlixsScale = 0;
    
    self.candleGap = 2;
    
    self.minCandleW = 5;
    self.maxCandleW = 35;
    
    self.curIndex = 0;
    self.longPressFlag = LONG_PRESS_FLAG_NONE;
    
    self.curBeginTouchPointX = -1;
    
    self.curBeginMutipleTouchPointXChange = -1;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)setModelsArray:(NSArray *)modelsArray
{
    _modelsArray = modelsArray;
    self.chartLineData = [self transformChartLineData];
    self.candleW = (CGRectGetWidth(self.bounds) - self.candleAreaPaddingLeft - self.candleAreaPaddingRight - self.candleGap * self.rangeSize)/self.rangeSize;
}

- (void)reCaculateChartData
{
    if (self.rangeFrom == -1) {
        self.rangeFrom = [self.modelsArray count] - self.rangeSize;
    }
    
    self.volumeMaxViewHeight = self.candleAreaPaddingDown - self.infoAreaPaddingDown - self.candleWithInfoAreaGap;
    
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
    
    self.yAlixsScale = (CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown - self.candleAreaPaddingTop - self.candleYAlixsToEdge*2)/(self.maxPrice - self.minPrice);
    
    //volume
    self.maxVolume = [self getMaxVolumeFromCurRange];
    self.volumeHScale = self.volumeMaxViewHeight/self.maxVolume;
}

- (void)renderMe
{
    [self reCaculateChartData];
    [self setNeedsDisplay];
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
    
    [self setNeedsDisplay];
}

#pragma mark - draw methods

- (void)drawRect:(CGRect)rect
{
    [self drawClearChart];
    if (CHECK_VALID_ARRAY(self.modelsArray)) {
        [self drawCandleAreaBorder];
        [self drawInfoAreaBorder];
        [self drawBackgroundDashLines];
        [self drawYAxis];
        [self drawXAxis];
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

- (void)drawBackground
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height));
}

- (void)drawTopInfoView
{
    float curLabelTop = 20;
    float labelW = 80;
    float labelH = 20;
    float labelGap = 10;
    float curLabelLeft = 60;
    
    HJCandleChartModel *candleModel = nil;
    float ma5Value = 0.0f;
    float ma10Value = 0.0f;
    float ma30Value = 0.0f;
    float ma60Value = 0.0f;
    
    if (self.longPressFlag!=LONG_PRESS_FLAG_INDEX) {
        candleModel = (HJCandleChartModel *)[self.modelsArray lastObject];
        ma5Value = [[((NSArray *)[self.chartLineData dataForKey:@"ma5"]) lastObject] floatValue];
        ma10Value = [[((NSArray *)[self.chartLineData dataForKey:@"ma10"]) lastObject] floatValue];
        ma30Value = [[((NSArray *)[self.chartLineData dataForKey:@"ma30"]) lastObject] floatValue];
        ma60Value = [[((NSArray *)[self.chartLineData dataForKey:@"ma60"]) lastObject] floatValue];
    }else {
        candleModel = (HJCandleChartModel *)[self.curDrawModesArray objectAtIndex:self.curIndex];
        ma5Value = [[self.curMA5Array objectAtIndex:self.curIndex+1] floatValue]
        ;
        ma10Value = [[self.curMA10Array objectAtIndex:self.curIndex+1] floatValue]
        ;
        ma30Value = [[self.curMA30Array objectAtIndex:self.curIndex+1] floatValue]
        ;
        ma60Value = [[self.curMA60Array objectAtIndex:self.curIndex+1] floatValue]
        ;
    }
    
    NSArray *volumeArray = [[self transformToUnitWithVolume:candleModel.volume] componentsSeparatedByString:@","];
    NSString *volumeStr = @"";
    if (CHECK_VALID_ARRAY(volumeArray)) {
        if ([volumeArray count]==2) {
            volumeStr = [NSString stringWithFormat:@"%@%@",[volumeArray firstObject],[volumeArray lastObject]];
        }else{
            volumeStr = [volumeArray firstObject];
        }
    }
    
    STOCK_FLAG flag = [self getStockFlagByCanleData:candleModel];
    
    if ([self.stockInfo count]==2) {
        [[NSString stringWithFormat:@"%@",[self.stockInfo lastObject]] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
        
        [[NSString stringWithFormat:@"%@",[self.stockInfo firstObject]] drawInRect:CGRectMake(curLabelLeft, curLabelTop+labelH+labelGap, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
        
        curLabelLeft += labelW + labelGap;
    }
    
    [[NSString stringWithFormat:@"Open:%.2f",[candleModel openPrice]] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"Close:%.2f",[candleModel closePrice]] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap), curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"High:%.2f",[candleModel highPrice]] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap)*2, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"Low:%.2f",[candleModel lowPrice]] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap)*3, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"Volume:%@",volumeStr] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap)*4, curLabelTop, labelW*2, labelH) withAttributes:[self getTopInfoAttributesByFlag:flag]];
    
    curLabelTop += labelH+labelGap;
    
    [[NSString stringWithFormat:@"MA5:%.2f",ma5Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA5]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA10:%.2f",ma10Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA10]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA30:%.2f",ma30Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA30]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA60:%.2f",ma60Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_MA60]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"Date:%@",[candleModel date]] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW*2, labelH) withAttributes:[self getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
}

- (void)drawCandleAreaBorder
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    if (self.longPressFlag == LONG_PRESS_FLAG_CHANGE_AREA) {
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_CHANGE_AREA] setStroke];
    }else {
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_NONE] setStroke];
    }
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, self.candleAreaPaddingTop);
    CGContextAddLineToPoint(context, self.candleAreaPaddingLeft, CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetWidth(self.bounds)-self.candleAreaPaddingRight, self.candleAreaPaddingTop);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds)-self.candleAreaPaddingRight, CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, self.candleAreaPaddingTop);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, self.candleAreaPaddingTop);
    CGContextStrokePath(context);
}

- (void)drawInfoAreaBorder
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    if (self.longPressFlag == LONG_PRESS_FLAG_CHANGE_AREA) {
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_CHANGE_AREA] setStroke];
    }else {
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_NONE] setStroke];
    }

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:self.maxVolume]);
    CGContextAddLineToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:0]);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:self.maxVolume]);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:0]);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:self.maxVolume]);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:self.maxVolume]);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:0.0f]);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:0.0f]);
    CGContextStrokePath(context);
}

- (void)drawBackgroundDashLines
{
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.maxPrice]];
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.averagePrice]];
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.minPrice]];
    
    [self drawDashLinesWithYPoint:[self transformVolumeToYPoint:self.maxVolume/2]];
}

- (void)drawDashLinesWithYPoint:(float)pointY
{
    CGFloat length[] = {10,5};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 2);
    [[self getColorByStockFlag:STOCK_FLAG_DASH] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, pointY);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, pointY);
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, NULL, 0);//必须加，为了保证不影响其他样式的绘制
}

- (void)drawDashLinesWithXPoint:(float)pointX
{
    CGFloat length[] = {10,5};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 2);
    [[self getColorByStockFlag:STOCK_FLAG_DASH] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, pointX, self.candleAreaPaddingTop);
    CGContextAddLineToPoint(context, pointX, CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown);
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, NULL, 0);//必须加，为了保证不影响其他样式的绘制
}

- (void)drawSolidLineWithYPoint:(float)pointY
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1);
    [[self getColorByStockFlag:STOCK_FLAG_DEFAULT] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, pointY);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, pointY);
    CGContextStrokePath(context);
}

- (void)drawIndexLineWithIndex:(long)index
{
    if (self.longPressFlag != LONG_PRESS_FLAG_INDEX) {
        return;
    }
    
    float pointX = self.candleAreaPaddingLeft + index*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
    
    float pointY = [self transformPriceToYPoint:[[self.curDrawModesArray objectAtIndex:index] closePrice]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self getColorByLongPressFlag:LONG_PRESS_FLAG_INDEX] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, pointX, self.candleAreaPaddingTop);
    CGContextAddLineToPoint(context, pointX, CGRectGetHeight(self.bounds)-self.infoAreaPaddingDown);
    CGContextStrokePath(context);
    
    [[self getColorByLongPressFlag:LONG_PRESS_FLAG_INDEX] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, pointY);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds)-self.candleAreaPaddingRight,pointY);
    CGContextStrokePath(context);
    
    //边框圆
    [[self getColorByStockFlag:STOCK_FLAG_DEFAULT] setStroke];
    CGContextSetLineWidth(context, 1);
    CGContextAddArc(context, pointX, pointY, self.candleW/2, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    //填充圆
    [[self getColorByLongPressFlag:LONG_PRESS_FLAG_INDEX] setFill];
    CGContextAddArc(context, pointX, pointY, self.candleW/4, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);//绘制填充
}

- (void)drawYAxis
{
    //绘制纵坐标值
    float labelH = 9;
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [self getColorByStockFlag:STOCK_FLAG_DEFAULT];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [[NSString stringWithFormat:@"%.2f",self.maxPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.maxPrice] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.averagePrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.averagePrice] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.minPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.minPrice] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
}

- (void)drawXAxis
{
    float labelH = 9;
    float labelW = 50;
    float pointY = CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown + 5;
    float globalChg = self.candleAreaPaddingLeft - self.candleW/2 - labelW/2;
    
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [self getColorByStockFlag:STOCK_FLAG_DEFAULT];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    NSArray *dateIndexArr = [self getDateIndexFromCandleModels:self.curDrawModesArray];
    
    for (NSNumber *num in dateIndexArr) {
        int curIndex = [num intValue];
        HJCandleChartModel *candle = [self.curDrawModesArray objectAtIndex:curIndex];
        
        float pointX = curIndex*(self.candleGap + self.candleW) + globalChg;
        
        [candle.date drawInRect:CGRectMake(pointX, pointY, labelW, labelH) withAttributes:attributes];
        [self drawDashLinesWithXPoint:pointX+labelW/2];
    }
}

- (void)drawCandleVeiwsAndVolumeViews
{
    int i = 0;
    for (HJCandleChartModel *candle in self.curDrawModesArray) {
        
        float pointX = self.candleAreaPaddingLeft + i*(self.candleGap + self.candleW) + self.candleGap;
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
            if (openPricePoint > closePricePoint) {
                flag = STOCK_FLAG_UP;
            }else {
                flag = STOCK_FLAG_DEFAULT;
            }
            
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
    [[self getColorByStockFlag:flag] setFill];
    [[self getColorByStockFlag:flag] setStroke];
    CGContextSetLineWidth(currentContext, 0.5f);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    CGPathRelease(path);
}

- (void)drawHatchWithPointA:(float)pointA pointB:(float)pointB linePX:(float)linePX flag:(STOCK_FLAG)flag
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self getColorByStockFlag:flag] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, linePX, pointA);
    CGContextAddLineToPoint(context, linePX, pointB);
    CGContextStrokePath(context);
}

- (void)drawVolumeTips
{
    float labelH = 9;
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [self getColorByStockFlag:STOCK_FLAG_DEFAULT];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    NSString *maxVolumeStr = [self transformToUnitWithVolume:self.maxVolume];
    
    NSArray *maxVolumeArray = [maxVolumeStr componentsSeparatedByString:@","];
    
    if (CHECK_VALID_ARRAY(maxVolumeArray)) {
        [[maxVolumeArray firstObject] drawInRect:CGRectMake(0, [self transformVolumeToYPoint:self.maxVolume] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
        if ([maxVolumeArray count]==2) {
            [[maxVolumeArray lastObject] drawInRect:CGRectMake(0, [self transformVolumeToYPoint:0] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
        }else {
            [@"0" drawInRect:CGRectMake(0, [self transformVolumeToYPoint:0] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
        }
    }
}

- (void)drawVolumeWithPoint:(float)volumeYPoint pointX:(float)pointX flag:(STOCK_FLAG)flag
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rectangle = CGRectMake(pointX, volumeYPoint, self.candleW, CGRectGetHeight(self.bounds) - volumeYPoint - self.infoAreaPaddingDown);
    CGPathAddRect(path, NULL, rectangle);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);
    [[self getColorByStockFlag:flag] setFill];
    [[self getColorByStockFlag:flag] setStroke];
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
    [[self getColorByStockFlag:flag] setStroke];
    CGContextBeginPath(context);
    
    for (int i=0; i<[maArr count]; i++) {
        float maValue = [[maArr objectAtIndex:i] floatValue];
        float pointX = self.candleAreaPaddingLeft;
        
        if (i==0) {
            CGContextMoveToPoint(context, pointX, [self transformPriceToYPoint:maValue]);
        }else {
            pointX = self.candleAreaPaddingLeft + (i-1)*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
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

- (float)transformPriceToYPoint:(float)priceValue
{
    return CGRectGetHeight(self.bounds) - (priceValue - self.minPrice)*self.yAlixsScale - self.candleAreaPaddingDown - self.candleYAlixsToEdge;
}

- (float)transformVolumeToYPoint:(long)volume
{
    return CGRectGetHeight(self.bounds) - volume*self.volumeHScale - self.infoAreaPaddingDown;
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

- (UIColor *)getColorByLongPressFlag:(LONG_PRESS_FLAG)flag
{
    switch (flag) {
        case LONG_PRESS_FLAG_INDEX:
            return [UIColor colorWithRed:44.0f/255.0f green:189.0f/255.0f blue:289.0f/255.0f alpha:1];
            break;
        case LONG_PRESS_FLAG_CHANGE_AREA:
            return [UIColor colorWithRed:0.99f green:0.69f blue:0.19f alpha:1];
            break;
            
        default:
            return [self getColorByStockFlag:STOCK_FLAG_DEFAULT];
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

- (long)getIndexByPointX:(float)pointX
{
    if (pointX>=CGRectGetWidth(self.bounds)-self.candleAreaPaddingRight) {
        return [self.curDrawModesArray count]-1;
    }else if(pointX<=self.candleAreaPaddingLeft) {
        return 0;
    }else {
        return (pointX - self.candleAreaPaddingLeft)/(self.candleW + self.candleGap);
    }
}

#pragma mark - touch event

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    float screenH = CGRectGetHeight(self.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if (point.y >= screenH - self.candleAreaPaddingDown && point.y <= screenH - self.candleAreaPaddingDown + self.candleWithInfoAreaGap) {
            self.longPressFlag = LONG_PRESS_FLAG_CHANGE_AREA;
            self.curBeginLongPressPointY = point.y;
            
            [self renderMe];
        }else {
            self.longPressFlag = LONG_PRESS_FLAG_INDEX;
            self.curIndex = [self getIndexByPointX:point.x];
            
            [self setNeedsDisplay];
        }
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        switch (self.longPressFlag) {
            case LONG_PRESS_FLAG_INDEX:
            {
                self.curIndex = [self getIndexByPointX:point.x];
                
                [self setNeedsDisplay];
            }
                break;
            case LONG_PRESS_FLAG_CHANGE_AREA:
            {
                float chgedPaddingDown = self.candleAreaPaddingDown - (point.y - self.curBeginLongPressPointY);
                if (chgedPaddingDown >= self.candleAreaMinPaddingDown && chgedPaddingDown <= self.candleAreaMaxPaddingDown) {
                    
                    self.curBeginLongPressPointY = point.y;
                    self.candleAreaPaddingDown = chgedPaddingDown;
                    
                    [self renderMe];
                }
            }
                break;
                
            default:
                break;
        }
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        self.longPressFlag = LONG_PRESS_FLAG_NONE;
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *ts = [[event allTouches] allObjects];
    if([ts count]==1) {
        self.curBeginMutipleTouchPointXChange = -1;
        
        UITouch* touch = ts[0];
        float touchPointX = [touch locationInView:self].x;
        float touchPointY = [touch locationInView:self].y;
        
        if(touchPointX > self.candleAreaPaddingLeft && touchPointX < CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight && touchPointY > self.candleAreaPaddingTop){
            self.curBeginTouchPointX = touchPointX;
        }
    }else if ([ts count]==2) {
        self.curBeginTouchPointX = -1;
        
        self.curBeginMutipleTouchPointXChange = fabs([ts[0] locationInView:self].x - [ts[1] locationInView:self].x);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *ts = [[event allTouches] allObjects];
    if([ts count]==1) {
        self.curBeginMutipleTouchPointXChange = -1;
        
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
                    if (self.rangeFrom + self.rangeSize == [self.modelsArray count]) {
                        return;
                    }else if (self.rangeFrom + self.rangeSize + indexChg > [self.modelsArray count]) {
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
        self.curBeginTouchPointX = -1;
        
        float currFlag = [ts[0] locationInView:self].x;
        float currFlagTwo = [ts[1] locationInView:self].x;
        
        if (self.curBeginMutipleTouchPointXChange == -1) {
            self.curBeginMutipleTouchPointXChange = fabs(currFlag - currFlagTwo);
        }else {
            float curChg = fabs(currFlag - currFlagTwo);
            float curScale = curChg/self.curBeginMutipleTouchPointXChange;
            float curCandleW = self.candleW;
            
            if (curCandleW * curScale < self.minCandleW) {
                curCandleW = self.minCandleW;
            }else if (curCandleW * curScale > self.maxCandleW) {
                curCandleW = self.maxCandleW;
            }else {
                curCandleW = self.candleW*curScale;
            }
            
            long curRangeSize = (CGRectGetWidth(self.bounds) - self.candleAreaPaddingLeft - self.candleAreaPaddingRight)/(curCandleW + self.candleGap);
            long curRangeFrom = self.rangeFrom;
            
            if (curRangeSize > self.rangeSize) {
                if (curRangeFrom==0) {
                    curRangeFrom = 0;
                }else if (curRangeFrom + curRangeSize >= [self.modelsArray count]){
                    curRangeFrom = [self.modelsArray count] - curRangeSize;
                }else {
                    curRangeFrom = self.rangeFrom - ceil((curRangeSize - self.rangeSize)/2);
                }
            }else if (curRangeSize < self.rangeSize){
                curRangeFrom = self.rangeFrom + floor((self.rangeSize - curRangeSize)/2);
            }else {
                self.curBeginMutipleTouchPointXChange = curChg;
                return;
            }
            
            self.rangeSize = curRangeSize;
            self.candleW = (CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight - self.candleAreaPaddingLeft)/self.rangeSize - self.candleGap;//需要重新计算准确的candle宽度值
            self.rangeFrom = curRangeFrom;
            
            /**
             *  做最后的容错处理
             */
            if (self.rangeFrom < 0) {
                self.rangeFrom = 0;
            }
            
            if (self.rangeFrom + self.rangeSize > [self.modelsArray count]) {
                self.rangeSize = [self.modelsArray count] - self.rangeFrom;
            }
            
            self.curBeginMutipleTouchPointXChange = curChg;
            
            [self renderMe];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.curBeginTouchPointX = -1;
    self.curBeginMutipleTouchPointXChange = -1;
}

@end
