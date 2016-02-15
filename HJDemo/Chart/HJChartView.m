//
//  HJChartView.m
//  HJDemo
//
//  Created by jixuhui on 16/1/14.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import "HJChartView.h"
#import "HJCandleChartModel.h"

typedef enum _LONG_PRESS_FLAG {
    LONG_PRESS_FLAG_NONE = 0,
    LONG_PRESS_FLAG_INDEX,
    LONG_PRESS_FLAG_CHANGE_AREA
}LONG_PRESS_FLAG;

@interface HJChartView()

//candleAreaPadding
@property (nonatomic) float candleAreaPaddingLeft;
@property (nonatomic) float candleAreaPaddingRight;
@property (nonatomic) float candleAreaPaddingTop;
@property (nonatomic) float candleAreaPaddingDown;
@property (nonatomic) float candleAreaMaxPaddingDown;
@property (nonatomic) float candleAreaMinPaddingDown;
@property (nonatomic) float infoAreaPaddingDown;
//infoArea vs candleArea Gap
@property (nonatomic) float candleWithInfoAreaGap;

@property (nonatomic) float yAlixsScale;
@property (nonatomic) float volumeHScale;
@property (nonatomic) float kdjHScale;
@property (nonatomic) float rsiHScale;
@property (nonatomic) float candleYAlixsToEdge;
@property (nonatomic) float candleGap;
@property (nonatomic) float candleW;
@property (nonatomic) float minCandleW;
@property (nonatomic) float maxCandleW;
@property (nonatomic) float infoAreaMaxViewHeight;
@property (nonatomic) long curIndex;
@property (nonatomic) LONG_PRESS_FLAG longPressFlag;
@property (nonatomic) float curBeginLongPressPointY;
@property (nonatomic) float curBeginTouchPointX;
@property (nonatomic) float curBeginMutipleTouchPointXChange;

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

- (instancetype)initWithViewModel:(HJChartViewModel *)viewModel
{
    self = [self init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)initChart
{
    self.candleYAlixsToEdge = 20;
    
    self.candleAreaPaddingLeft = 50;
    self.candleAreaPaddingRight = 10+50+10;
    self.candleAreaPaddingTop = 90;
    self.candleAreaPaddingDown = 120;
    self.candleAreaMaxPaddingDown = 230;
    self.candleAreaMinPaddingDown = 80;
    
    self.candleWithInfoAreaGap = 20;
    self.infoAreaPaddingDown = 40;
    
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

- (void)reCaculateChartData
{
    [self.viewModel reCaculateChartData];
    
    self.candleW = (CGRectGetWidth(self.bounds) - self.candleAreaPaddingLeft - self.candleAreaPaddingRight - self.candleGap * self.viewModel.rangeSize)/self.viewModel.rangeSize;
    
    self.infoAreaMaxViewHeight = self.candleAreaPaddingDown - self.infoAreaPaddingDown - self.candleWithInfoAreaGap;
    
    self.volumeHScale = self.infoAreaMaxViewHeight/self.viewModel.maxVolume;
    
    self.yAlixsScale = (CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown - self.candleAreaPaddingTop - self.candleYAlixsToEdge*2)/(self.viewModel.maxPrice - self.viewModel.minPrice);
   
    self.kdjHScale = self.infoAreaMaxViewHeight/(self.viewModel.maxKDJValue - self.viewModel.minKDJValue);
    
    self.rsiHScale = self.infoAreaMaxViewHeight/(self.viewModel.maxRSIValue - self.viewModel.minRSIValue);
}

- (void)renderMe
{
    [self reCaculateChartData];
    [self setNeedsDisplay];
}

- (void)resetMe
{
    [self.viewModel resetMe];
    [self setNeedsDisplay];
}

#pragma mark - draw methods

- (void)drawRect:(CGRect)rect
{
    [self drawClearChart];
    if (CHECK_VALID_ARRAY(self.viewModel.modelsArray)) {
        [self drawCandleAreaBorder];
        [self drawInfoAreaBorder];
        [self drawBackgroundDashLines];
        [self drawYAxis];
        [self drawXAxis];
        [self drawInfoTips];
        [self drawCandleVeiwsAndInfoViews];
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
        candleModel = (HJCandleChartModel *)[self.viewModel.modelsArray lastObject];
        ma5Value = [[((NSArray *)[self.viewModel.chartLineData dataForKey:@"ma5"]) lastObject] floatValue];
        ma10Value = [[((NSArray *)[self.viewModel.chartLineData dataForKey:@"ma10"]) lastObject] floatValue];
        ma30Value = [[((NSArray *)[self.viewModel.chartLineData dataForKey:@"ma30"]) lastObject] floatValue];
        ma60Value = [[((NSArray *)[self.viewModel.chartLineData dataForKey:@"ma60"]) lastObject] floatValue];
    }else {
        candleModel = (HJCandleChartModel *)[self.viewModel.curDrawModesArray objectAtIndex:self.curIndex];
        ma5Value = [[self.viewModel.curMA5Array objectAtIndex:self.curIndex+1] floatValue]
        ;
        ma10Value = [[self.viewModel.curMA10Array objectAtIndex:self.curIndex+1] floatValue]
        ;
        ma30Value = [[self.viewModel.curMA30Array objectAtIndex:self.curIndex+1] floatValue]
        ;
        ma60Value = [[self.viewModel.curMA60Array objectAtIndex:self.curIndex+1] floatValue]
        ;
    }
    
    NSArray *volumeArray = [[self.viewModel transformToUnitWithVolume:candleModel.volume/100] componentsSeparatedByString:@","];
    NSString *volumeStr = @"";
    if (CHECK_VALID_ARRAY(volumeArray)) {
        if ([volumeArray count]==2) {
            volumeStr = [NSString stringWithFormat:@"%@%@",[volumeArray firstObject],[volumeArray lastObject]];
        }else{
            volumeStr = [volumeArray firstObject];
        }
    }
    
    STOCK_FLAG flag = [self.viewModel getStockFlagByCanleData:candleModel];
    
    if ([self.viewModel.stockInfo count]==2) {
        [[NSString stringWithFormat:@"%@",[self.viewModel.stockInfo lastObject]] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
        
        [[NSString stringWithFormat:@"%@",[self.viewModel.stockInfo firstObject]] drawInRect:CGRectMake(curLabelLeft, curLabelTop+labelH+labelGap, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
        
        curLabelLeft += labelW + labelGap;
    }
    
    [[NSString stringWithFormat:@"Open:%.2f",[candleModel openPrice]] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"Close:%.2f",[candleModel closePrice]] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap), curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"High:%.2f",[candleModel highPrice]] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap)*2, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"Low:%.2f",[candleModel lowPrice]] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap)*3, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:flag]];
    
    [[NSString stringWithFormat:@"Volume:%@",volumeStr] drawInRect:CGRectMake(curLabelLeft+(labelW+labelGap)*4, curLabelTop, labelW*2, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:flag]];
    
    curLabelTop += labelH+labelGap;
    
    [[NSString stringWithFormat:@"MA5:%.2f",ma5Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_MA5]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA10:%.2f",ma10Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_MA10]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA30:%.2f",ma30Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_MA30]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"MA60:%.2f",ma60Value] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_MA60]];
    
    curLabelLeft += labelW + labelGap;
    
    [[NSString stringWithFormat:@"Date:%@",[candleModel date]] drawInRect:CGRectMake(curLabelLeft, curLabelTop, labelW*2, labelH) withAttributes:[self.viewModel getTopInfoAttributesByFlag:STOCK_FLAG_DEFAULT]];
}

- (void)drawCandleAreaBorder
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    if (self.longPressFlag == LONG_PRESS_FLAG_CHANGE_AREA) {
        CGContextSetLineWidth(context, 1);
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_CHANGE_AREA] setStroke];
    }else {
        CGContextSetLineWidth(context, 0.5);
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
    if (self.longPressFlag == LONG_PRESS_FLAG_CHANGE_AREA) {
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_CHANGE_AREA] setStroke];
        CGContextSetLineWidth(context, 1);
    }else {
        [[self getColorByLongPressFlag:LONG_PRESS_FLAG_NONE] setStroke];
        CGContextSetLineWidth(context, 0.5);
    }

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:self.viewModel.maxVolume]);
    CGContextAddLineToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:0]);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:self.viewModel.maxVolume]);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:0]);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:self.viewModel.maxVolume]);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:self.viewModel.maxVolume]);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.candleAreaPaddingLeft, [self transformVolumeToYPoint:0.0f]);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight, [self transformVolumeToYPoint:0.0f]);
    CGContextStrokePath(context);
}

- (void)drawBackgroundDashLines
{
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.viewModel.maxPrice]];
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.viewModel.averagePrice]];
    [self drawDashLinesWithYPoint:[self transformPriceToYPoint:self.viewModel.minPrice]];
    
    [self drawDashLinesWithYPoint:[self transformVolumeToYPoint:self.viewModel.maxVolume/2]];
}

- (void)drawDashLinesWithYPoint:(float)pointY
{
    CGFloat length[] = {10,5};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 2);
    [[self.viewModel getColorByStockFlag:STOCK_FLAG_DASH] setStroke];
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
    [[self.viewModel getColorByStockFlag:STOCK_FLAG_DASH] setStroke];
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
    [[self.viewModel getColorByStockFlag:STOCK_FLAG_DEFAULT] setStroke];
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
    
    float pointY = [self transformPriceToYPoint:[[self.viewModel.curDrawModesArray objectAtIndex:index] closePrice]];
    
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
    [[self.viewModel getColorByStockFlag:STOCK_FLAG_DEFAULT] setStroke];
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
    UIColor *color = [self.viewModel getColorByStockFlag:STOCK_FLAG_DEFAULT];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [[NSString stringWithFormat:@"%.2f",self.viewModel.maxPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.viewModel.maxPrice] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.viewModel.averagePrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.viewModel.averagePrice] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.viewModel.minPrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:self.viewModel.minPrice] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
}

- (void)drawXAxis
{
    float labelH = 9;
    float labelW = 50;
    float pointY = CGRectGetHeight(self.bounds) - self.candleAreaPaddingDown + 5;
    float globalChg = self.candleAreaPaddingLeft - self.candleW/2 - labelW/2;
    
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [self.viewModel getColorByStockFlag:STOCK_FLAG_DEFAULT];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    NSArray *dateIndexArr = [self.viewModel getDateIndexFromCandleModels:self.viewModel.curDrawModesArray];
    
    for (NSNumber *num in dateIndexArr) {
        int curIndex = [num intValue];
        HJCandleChartModel *candle = [self.viewModel.curDrawModesArray objectAtIndex:curIndex];
        
        float pointX = (curIndex+1)*(self.candleGap + self.candleW) + globalChg;
        
        [candle.date drawInRect:CGRectMake(pointX, pointY, labelW, labelH) withAttributes:attributes];
        [self drawDashLinesWithXPoint:pointX+labelW/2];
    }
}

- (void)drawCandleVeiwsAndInfoViews
{
    int i = 0;
    for (HJCandleChartModel *candle in self.viewModel.curDrawModesArray) {
        
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
        
        if (self.viewModel.infoType == CHART_INFO_TYPE_VOLUME) {
            float volumePoint = [self transformVolumeToYPoint:candle.volume];
            [self drawVolumeWithPoint:volumePoint pointX:pointX flag:flag];
        }
        
        i ++;
    }
    
    if (self.viewModel.infoType == CHART_INFO_TYPE_KDJ) {
        [self drawKDJWithFlag:KDJ_FLAG_K];
        [self drawKDJWithFlag:KDJ_FLAG_D];
        [self drawKDJWithFlag:KDJ_FLAG_J];
    }else if (self.viewModel.infoType == CHART_INFO_TYPE_RSI) {
        [self drawRSIWithFlag:RSI_FLAG_6];
        [self drawRSIWithFlag:RSI_FLAG_12];
        [self drawRSIWithFlag:RSI_FLAG_24];
    }
}

- (void)drawCandleWithPointA:(float)pointA pointB:(float)pointB pointX:(float)pointX flag:(STOCK_FLAG)flag
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rectangle = CGRectMake(pointX, MIN(pointA, pointB), self.candleW, fabs(pointA - pointB));
    CGPathAddRect(path, NULL, rectangle);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);
    [[self.viewModel getColorByStockFlag:flag] setFill];
    [[self.viewModel getColorByStockFlag:flag] setStroke];
    CGContextSetLineWidth(currentContext, 0.5f);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    CGPathRelease(path);
}

- (void)drawHatchWithPointA:(float)pointA pointB:(float)pointB linePX:(float)linePX flag:(STOCK_FLAG)flag
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self.viewModel getColorByStockFlag:flag] setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, linePX, pointA);
    CGContextAddLineToPoint(context, linePX, pointB);
    CGContextStrokePath(context);
}

- (void)drawInfoTips
{
    UIFont *font = [UIFont systemFontOfSize:8];
    UIColor *color = [self.viewModel getColorByStockFlag:STOCK_FLAG_DEFAULT];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName: font,
NSForegroundColorAttributeName: color,
NSParagraphStyleAttributeName: paragraphStyle}];
    
    switch (self.viewModel.infoType) {
        case CHART_INFO_TYPE_VOLUME:
            [self drawVolumeTipsWithAttributes:attributes];
            break;
        case CHART_INFO_TYPE_KDJ:
            [self drawKDJTipsWithAttributes:attributes];
            break;
        case CHART_INFO_TYPE_RSI:
            [self drawRSITipsWithAttributes:attributes];
            break;
        default:
            break;
    }
}

- (void)drawVolumeTipsWithAttributes:(NSDictionary *)attributes
{
    float labelH = 9;
    NSString *maxVolumeStr = [self.viewModel transformToUnitWithVolume:self.viewModel.maxVolume/100];//1手是一股
    NSArray *maxVolumeArray = [maxVolumeStr componentsSeparatedByString:@","];
    
    if (CHECK_VALID_ARRAY(maxVolumeArray)) {
        [[maxVolumeArray firstObject] drawInRect:CGRectMake(0, [self transformVolumeToYPoint:self.viewModel.maxVolume] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
        if ([maxVolumeArray count]==2) {
            [[maxVolumeArray lastObject] drawInRect:CGRectMake(0, [self transformVolumeToYPoint:0] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
        }else {
            [@"0" drawInRect:CGRectMake(0, [self transformVolumeToYPoint:0] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
        }
    }
}

- (void)drawKDJTipsWithAttributes:(NSMutableDictionary *)attributes
{
    float labelH = 9;
    float averageValue = (self.viewModel.maxKDJValue - self.viewModel.minKDJValue)/2;
    
    [[NSString stringWithFormat:@"%.2f",self.viewModel.maxKDJValue] drawInRect:CGRectMake(0, [self transformKDJToYPoint:self.viewModel.maxKDJValue] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",averageValue] drawInRect:CGRectMake(0, [self transformKDJToYPoint:averageValue] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.viewModel.minKDJValue] drawInRect:CGRectMake(0, [self transformKDJToYPoint:self.viewModel.minKDJValue] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    
    float left = self.candleAreaPaddingLeft + 2;
    float top = CGRectGetHeight(self.bounds)-self.infoAreaMaxViewHeight-self.infoAreaPaddingDown + 2;
    float gap = 10;
    
    if (self.longPressFlag == LONG_PRESS_FLAG_INDEX) {
        
        NSString *kStr = [NSString stringWithFormat:@"K:%@",[self.viewModel.curKArray objectAtIndex:self.curIndex]];
        float kLen = [kStr sizeWithAttributes:attributes].width;
        
        NSString *dStr = [NSString stringWithFormat:@"D:%@",[self.viewModel.curDArray objectAtIndex:self.curIndex]];
        float dLen = [dStr sizeWithAttributes:attributes].width;
        
        NSString *jStr = [NSString stringWithFormat:@"J:%@",[self.viewModel.curJArray objectAtIndex:self.curIndex]];
        float jLen = [jStr sizeWithAttributes:attributes].width;
        
        if (self.curIndex < floor([self.viewModel.curDrawModesArray count]/2)) {
            left = CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight - kLen - dLen - jLen - gap*2;
        }
        
        [attributes setValue:[self.viewModel getColorByKDJFlag:KDJ_FLAG_K] forKey:NSForegroundColorAttributeName];
        [kStr drawInRect:CGRectMake(left, top, kLen, labelH) withAttributes:attributes];
        
        left += kLen + gap;
        
        [attributes setValue:[self.viewModel getColorByKDJFlag:KDJ_FLAG_D] forKey:NSForegroundColorAttributeName];
        [dStr drawInRect:CGRectMake(left, top, dLen, labelH) withAttributes:attributes];
        
        left += dLen + gap;
        
        [attributes setValue:[self.viewModel getColorByKDJFlag:KDJ_FLAG_J] forKey:NSForegroundColorAttributeName];
        [jStr drawInRect:CGRectMake(left, top, jLen, labelH) withAttributes:attributes];
    }else {
        NSString *kdjStr = [NSString stringWithFormat:@"KDJ[9,3,3]"];
        float kdjLen = [kdjStr sizeWithAttributes:attributes].width;
        
        [kdjStr drawInRect:CGRectMake(left, top, kdjLen, labelH) withAttributes:attributes];
    }
}

- (void)drawRSITipsWithAttributes:(NSMutableDictionary *)attributes
{
    float labelH = 9;
    float averageValue = (self.viewModel.maxRSIValue - self.viewModel.minRSIValue)/2;
    
    [[NSString stringWithFormat:@"%.2f",self.viewModel.maxRSIValue] drawInRect:CGRectMake(0, [self transformRSIToYPoint:self.viewModel.maxRSIValue] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",averageValue] drawInRect:CGRectMake(0, [self transformRSIToYPoint:averageValue] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    [[NSString stringWithFormat:@"%.2f",self.viewModel.minRSIValue] drawInRect:CGRectMake(0, [self transformRSIToYPoint:self.viewModel.minRSIValue] - labelH/2, self.candleAreaPaddingLeft-2, labelH) withAttributes:attributes];
    
    float left = self.candleAreaPaddingLeft + 2;
    float top = CGRectGetHeight(self.bounds)-self.infoAreaMaxViewHeight-self.infoAreaPaddingDown + 2;
    float gap = 10;
    
    if (self.longPressFlag == LONG_PRESS_FLAG_INDEX) {
        
        NSString *kStr = [NSString stringWithFormat:@"RSI6:%@",[self.viewModel.curKArray objectAtIndex:self.curIndex]];
        float kLen = [kStr sizeWithAttributes:attributes].width;
        
        NSString *dStr = [NSString stringWithFormat:@"RSI12:%@",[self.viewModel.curDArray objectAtIndex:self.curIndex]];
        float dLen = [dStr sizeWithAttributes:attributes].width;
        
        NSString *jStr = [NSString stringWithFormat:@"RSI24:%@",[self.viewModel.curJArray objectAtIndex:self.curIndex]];
        float jLen = [jStr sizeWithAttributes:attributes].width;
        
        if (self.curIndex < floor([self.viewModel.curDrawModesArray count]/2)) {
            left = CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight - kLen - dLen - jLen - gap*2;
        }
        
        [attributes setValue:[self.viewModel getColorByRSIFlag:RSI_FLAG_6] forKey:NSForegroundColorAttributeName];
        [kStr drawInRect:CGRectMake(left, top, kLen, labelH) withAttributes:attributes];
        
        left += kLen + gap;
        
        [attributes setValue:[self.viewModel getColorByRSIFlag:RSI_FLAG_12] forKey:NSForegroundColorAttributeName];
        [dStr drawInRect:CGRectMake(left, top, dLen, labelH) withAttributes:attributes];
        
        left += dLen + gap;
        
        [attributes setValue:[self.viewModel getColorByRSIFlag:RSI_FLAG_24] forKey:NSForegroundColorAttributeName];
        [jStr drawInRect:CGRectMake(left, top, jLen, labelH) withAttributes:attributes];
    }else {
        NSString *rsiStr = [NSString stringWithFormat:@"RSI[6,12,24]"];
        float rsiLen = [rsiStr sizeWithAttributes:attributes].width;
        
        [rsiStr drawInRect:CGRectMake(left, top, rsiLen, labelH) withAttributes:attributes];
    }
}

- (void)drawVolumeWithPoint:(float)volumeYPoint pointX:(float)pointX flag:(STOCK_FLAG)flag
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rectangle = CGRectMake(pointX, volumeYPoint, self.candleW, CGRectGetHeight(self.bounds) - volumeYPoint - self.infoAreaPaddingDown);
    CGPathAddRect(path, NULL, rectangle);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);
    [[self.viewModel getColorByStockFlag:flag] setFill];
    [[self.viewModel getColorByStockFlag:flag] setStroke];
    CGContextSetLineWidth(currentContext, 0.5f);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    CGPathRelease(path);
}

- (void)drawMAWithFlag:(STOCK_FLAG)flag
{
    NSArray *maArr = [self.viewModel getMAArrayByFlag:flag];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self.viewModel getColorByStockFlag:flag] setStroke];
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

- (void)drawKDJWithFlag:(KDJ_FLAG)flag
{
    NSArray *kdjArr = [self.viewModel getKDJArrayByFlag:flag];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self.viewModel getColorByKDJFlag:flag] setStroke];
    CGContextBeginPath(context);
    
    for (int i=0; i<[kdjArr count]; i++) {
        float maValue = [[kdjArr objectAtIndex:i] floatValue];
        float pointX = self.candleAreaPaddingLeft;
        
        if (i==0) {
            CGContextMoveToPoint(context, pointX, [self transformKDJToYPoint:maValue]);
        }else {
            pointX = self.candleAreaPaddingLeft + (i-1)*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
            CGContextAddLineToPoint(context, pointX, [self transformKDJToYPoint:maValue]);
        }
    }
    
    CGContextStrokePath(context);
}

- (void)drawRSIWithFlag:(RSI_FLAG)flag
{
    NSArray *rsiArr = [self.viewModel getRSIArrayByFlag:flag];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 0.5);
    [[self.viewModel getColorByRSIFlag:flag] setStroke];
    CGContextBeginPath(context);
    
    for (int i=0; i<[rsiArr count]; i++) {
        float maValue = [[rsiArr objectAtIndex:i] floatValue];
        float pointX = self.candleAreaPaddingLeft;
        
        if (i==0) {
            CGContextMoveToPoint(context, pointX, [self transformRSIToYPoint:maValue]);
        }else {
            pointX = self.candleAreaPaddingLeft + (i-1)*(self.candleGap + self.candleW) + self.candleGap + self.candleW/2;
            CGContextAddLineToPoint(context, pointX, [self transformRSIToYPoint:maValue]);
        }
    }
    
    CGContextStrokePath(context);
}

#pragma mark - help methods

- (float)transformPriceToYPoint:(float)priceValue
{
    return CGRectGetHeight(self.bounds) - (priceValue - self.viewModel.minPrice)*self.yAlixsScale - self.candleAreaPaddingDown - self.candleYAlixsToEdge;
}

- (float)transformVolumeToYPoint:(long)volume
{
    return CGRectGetHeight(self.bounds) - volume*self.volumeHScale - self.infoAreaPaddingDown;
}

- (float)transformKDJToYPoint:(float)kdjValue
{
    return CGRectGetHeight(self.bounds) - (kdjValue - self.viewModel.minKDJValue)*self.kdjHScale - self.infoAreaPaddingDown;
}

- (float)transformRSIToYPoint:(float)rsiValue
{
    return CGRectGetHeight(self.bounds) - (rsiValue - self.viewModel.minRSIValue)*self.rsiHScale - self.infoAreaPaddingDown;
}

- (long)getIndexByPointX:(float)pointX
{
    if (pointX>=CGRectGetWidth(self.bounds)-self.candleAreaPaddingRight) {
        return [self.viewModel.curDrawModesArray count]-1;
    }else if(pointX<=self.candleAreaPaddingLeft) {
        return 0;
    }else {
        return (pointX - self.candleAreaPaddingLeft)/(self.candleW + self.candleGap);
    }
}

- (UIColor *)getColorByLongPressFlag:(LONG_PRESS_FLAG)flag
{
    switch (flag) {
        case LONG_PRESS_FLAG_INDEX:
            return [UIColor colorWithRed:44.0f/255.0f green:189.0f/255.0f blue:289.0f/255.0f alpha:1];
            break;
        case LONG_PRESS_FLAG_CHANGE_AREA:
            return [UIColor colorWithRed:0.97f green:0.87f blue:0.5f alpha:0.8];
            break;
        default:
            return [self.viewModel getColorByStockFlag:STOCK_FLAG_DEFAULT];
            break;
    }
}

#pragma mark - touch event

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    float screenH = CGRectGetHeight(self.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if (point.y >= screenH - self.candleAreaPaddingDown - 10 && point.y <= screenH - self.candleAreaPaddingDown + self.candleWithInfoAreaGap + 10) {
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
                    if (self.viewModel.rangeFrom == 0) {
                        return;
                    }else if (self.viewModel.rangeFrom -indexChg < 0) {
                        self.viewModel.rangeFrom = 0;
                    }else {
                        self.viewModel.rangeFrom -= indexChg;
                    }
                }else {
                    if (self.viewModel.rangeFrom + self.viewModel.rangeSize == [self.viewModel.modelsArray count]) {
                        return;
                    }else if (self.viewModel.rangeFrom + self.viewModel.rangeSize + indexChg > [self.viewModel.modelsArray count]) {
                        self.viewModel.rangeFrom = [self.viewModel.modelsArray count] - self.viewModel.rangeSize;
                    }else {
                        self.viewModel.rangeFrom += indexChg;
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
            long curRangeFrom = self.viewModel.rangeFrom;
            
            if (curRangeSize > self.viewModel.rangeSize) {
                if (curRangeFrom==0) {
                    curRangeFrom = 0;
                }else if (curRangeFrom + curRangeSize >= [self.viewModel.modelsArray count]){
                    curRangeFrom = [self.viewModel.modelsArray count] - curRangeSize;
                }else {
                    curRangeFrom = self.viewModel.rangeFrom - ceil((curRangeSize - self.viewModel.rangeSize)/2);
                }
            }else if (curRangeSize < self.viewModel.rangeSize){
                curRangeFrom = self.viewModel.rangeFrom + floor((self.viewModel.rangeSize - curRangeSize)/2);
            }else {
                self.curBeginMutipleTouchPointXChange = curChg;
                return;
            }
            
            self.viewModel.rangeSize = curRangeSize;
            self.candleW = (CGRectGetWidth(self.bounds) - self.candleAreaPaddingRight - self.candleAreaPaddingLeft)/self.viewModel.rangeSize - self.candleGap;//需要重新计算准确的candle宽度值
            self.viewModel.rangeFrom = curRangeFrom;
            
            /**
             *  做最后的容错处理
             */
            if (self.viewModel.rangeFrom < 0) {
                self.viewModel.rangeFrom = 0;
            }
            
            if (self.viewModel.rangeFrom + self.viewModel.rangeSize > [self.viewModel.modelsArray count]) {
                self.viewModel.rangeSize = [self.viewModel.modelsArray count] - self.viewModel.rangeFrom;
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
