//
//  HJChartView.h
//  HJDemo
//
//  Created by jixuhui on 16/1/14.
//  Copyright © 2016年 Hubbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJChartViewModel.h"

@interface HJChartView : UIView

@property(assign,nonatomic) BOOL transformed;
@property (nonatomic,strong) HJChartViewModel *viewModel;

- (instancetype)initWithViewModel:(HJChartViewModel *)viewModel;
- (void)renderMe;
- (void)resetMe;

@end
