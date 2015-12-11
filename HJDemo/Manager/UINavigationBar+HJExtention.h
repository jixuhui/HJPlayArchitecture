//
//  UINavigationBar+HJExtention.h
//  HJDemo
//
//  Created by jixuhui on 15/12/11.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (HJExtention)

/**
 *  设置导航栏透明度
 *
 *  @param alpha
 */
- (void)hj_setBackgroundAlpha:(CGFloat)alpha;

/**
 *  设置导航栏背景颜色
 *
 *  @param color
 */
- (void)hj_setBackgroundColor:(UIColor *)color;

/**
 *  重置导航栏的状态，恢复到初始时的状态
 */
- (void)hj_reset;

@end
