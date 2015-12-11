//
//  HJParallaxHeaderManager.h
//  HJDemo
//
//  Created by jixuhui on 15/12/11.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJParallaxHeaderManager : NSObject <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIView* targetView;
/**
 *   向上滚动时，背景与scrollview offsetY的视差倍率，默认0.6
 */
@property (nonatomic, assign) IBInspectable CGFloat offsetMultiple;

@end
