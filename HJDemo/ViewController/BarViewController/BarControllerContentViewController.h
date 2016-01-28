//
//  BarControllerContentViewController.h
//  HJDemo
//
//  Created by jixuhui on 15/11/12.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarControllerContentViewController : UIViewController
@property(nonatomic,assign) UIEdgeInsets padding;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)showSimpleAlertByMessgae:(NSString *)message;
@end
