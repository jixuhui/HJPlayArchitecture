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
    STOCK_FLAG_DOWN
}STOCK_FLAG;

@interface HJChartView()

@property (nonatomic) float yAlixsScale;
@property (nonatomic) float maxPrice;
@property (nonatomic) float minPrice;
@property (nonatomic) float candleGap;
@property (nonatomic) float candleW;

@end

@implementation HJChartView

- (instancetype)initWithData:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.modelsArray = array;
        
        self.paddingLeft = 30;
        self.paddingRight = 10;
        self.paddingTop = 10;
        self.paddingDown = 10;
        
        self.rangeSize = 50;
        self.rangeFrom = [self.modelsArray count] - self.rangeSize;
        
        self.yAlixsScale = 0;
        
        self.candleGap = 2;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self initChart];
    [self drawYAxis];
    [self drawXAxis];
    [self drawCandleVeiws];
}

- (void)initChart
{
    NSIndexSet *se = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.rangeFrom, self.rangeSize)];
    self.curDrawModesArray = [self.modelsArray objectsAtIndexes:se];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height));
}

- (void)drawYAxis
{
    //绘制纵轴
    self.maxPrice = [self getHighPriceModelFromCurRange];
    self.minPrice = [self getLowPriceModelFromCurRange];
    float averagePrice = (self.maxPrice + self.minPrice)/2;
    
    self.yAlixsScale = (CGRectGetHeight(self.bounds) - self.paddingDown - self.paddingTop)/(self.maxPrice - self.minPrice);
    self.candleW = (CGRectGetWidth(self.bounds) - self.paddingLeft - self.paddingRight - self.candleGap * self.rangeSize)/self.rangeSize;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.paddingLeft, self.paddingDown);
    CGContextAddLineToPoint(context, self.paddingLeft, CGRectGetHeight(self.bounds) - self.paddingTop);
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
    [[NSString stringWithFormat:@"%.2f",averagePrice] drawInRect:CGRectMake(0, [self transformPriceToYPoint:averagePrice] - labelH/2, self.paddingLeft-2, labelH) withAttributes:attributes];
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
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect rectangle = CGRectMake(pointX, openPricePoint, self.candleW, fabsf(openPricePoint - closePricePoint));
            CGPathAddRect(path, NULL, rectangle);
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            CGContextAddPath(currentContext, path);
            [[self getColorByFlag:STOCK_FLAG_DOWN] setFill];
            [[self getColorByFlag:STOCK_FLAG_DOWN] setStroke];
            CGContextSetLineWidth(currentContext, 0.5f);
            CGContextDrawPath(currentContext, kCGPathFillStroke);
            CGPathRelease(path);
            
            //绘制上影线
            if (highPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:highPricePoint linePX:linePX flag:STOCK_FLAG_DOWN];
            }
            
            //绘制下影线
            if (lowPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:lowPricePoint linePX:linePX flag:STOCK_FLAG_DOWN];
            }
        }else if (openPricePoint > closePricePoint) {
            //涨了 先绘制蜡烛
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect rectangle = CGRectMake(pointX, closePricePoint, self.candleW, fabs(closePricePoint - openPricePoint));
            CGPathAddRect(path, NULL, rectangle);
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            CGContextAddPath(currentContext, path);
            [[self getColorByFlag:STOCK_FLAG_UP] setFill];
            [[self getColorByFlag:STOCK_FLAG_UP] setStroke];
            CGContextSetLineWidth(currentContext, 0.5f);
            CGContextDrawPath(currentContext, kCGPathFillStroke);
            CGPathRelease(path);
            //绘制上影线
            if (highPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:highPricePoint linePX:linePX flag:STOCK_FLAG_UP];
            }
            //绘制下影线
            if (lowPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:lowPricePoint linePX:linePX flag:STOCK_FLAG_UP];
            }
        }else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineCap(context, kCGLineCapSquare);
            CGContextSetLineWidth(context, 0.5);
            [[self getColorByFlag:STOCK_FLAG_UP] setStroke];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, pointX, openPricePoint);
            CGContextAddLineToPoint(context, pointX+self.candleW, closePricePoint);
            CGContextStrokePath(context);
            
            //绘制上影线
            if (highPricePoint != closePricePoint) {
                [self drawHatchWithPointA:closePricePoint pointB:highPricePoint linePX:linePX flag:STOCK_FLAG_UP];
            }
            //绘制下影线
            if (lowPricePoint != openPricePoint) {
                [self drawHatchWithPointA:openPricePoint pointB:lowPricePoint linePX:linePX flag:STOCK_FLAG_UP];
            }
        }
        
        i ++;
    }
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

- (UIColor *)getColorByFlag:(STOCK_FLAG)flag
{
    switch (flag) {
        case STOCK_FLAG_UP:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
        case STOCK_FLAG_DOWN:
            return [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
            break;
        default:
            return [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            break;
    }
}

#pragma mark - help methods

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

@end
