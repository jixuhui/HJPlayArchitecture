//
//  UINavigationBar+HJExtention.m
//  HJDemo
//
//  Created by jixuhui on 15/12/11.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "UINavigationBar+HJExtention.h"

@interface UINavigationBar ()

@property (nonatomic, assign) BOOL     hjOriginIsTranslucent;
@property (nonatomic, strong) UIImage *hjOriginBackgroundImage;
@property (nonatomic, strong) UIImage *hjOriginShadowImage;
@property (nonatomic, strong) UIView  *hjBackgroundView;

@end

@implementation UINavigationBar (HJExtention)

- (void)hj_setBackgroundAlpha:(CGFloat)alpha{
    [self hj_setBackgroundColor:[self.barTintColor colorWithAlphaComponent:alpha]];
}

- (void)hj_setBackgroundColor:(UIColor *)color{
    if (!self.hjBackgroundView) {
        self.hjOriginBackgroundImage = [self backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.hjOriginShadowImage     = self.shadowImage;
        self.hjOriginIsTranslucent   = self.translucent;
        
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:nil];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, self.bounds.size.height + 20)];
        bgView.userInteractionEnabled = NO;
        [self insertSubview:bgView atIndex:0];
        
        self.hjBackgroundView = bgView;
        self.translucent       = YES;
        
    }
    self.hjBackgroundView.backgroundColor = color;
    
}

- (void)hj_reset{
    [self setBackgroundImage:self.hjOriginBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:self.hjOriginShadowImage];
    [self setTranslucent:self.hjOriginIsTranslucent];
    
    [self.hjBackgroundView removeFromSuperview];
    self.hjOriginBackgroundImage = nil;
    self.hjOriginShadowImage     = nil;
    self.hjBackgroundView        = nil;
}

#pragma mark- getters & setters

- (UIImage *)hjOriginBackgroundImage{
    return objc_getAssociatedObject(self, @selector(hjOriginBackgroundImage));
}
- (void)setHjOriginBackgroundImage:(UIImage *)hjOriginBackgroundImage{
    objc_setAssociatedObject(self, @selector(hjOriginBackgroundImage), hjOriginBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)hjOriginShadowImage{
    return objc_getAssociatedObject(self, @selector(hjOriginShadowImage));
}
- (void)setHjOriginShadowImage:(UIImage *)hjOriginShadowImage{
    objc_setAssociatedObject(self, @selector(hjOriginShadowImage), hjOriginShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)hjBackgroundView{
    return objc_getAssociatedObject(self, @selector(hjBackgroundView));
}

- (void)setHjBackgroundView:(UIView *)hjBackgroundView{
    objc_setAssociatedObject(self, @selector(hjBackgroundView), hjBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hjOriginIsTranslucent{
    return [objc_getAssociatedObject(self, @selector(hjOriginIsTranslucent)) boolValue];
}
- (void)setHjOriginIsTranslucent:(BOOL)hjOriginIsTranslucent{
    objc_setAssociatedObject(self, @selector(hjOriginIsTranslucent), @(hjOriginIsTranslucent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
