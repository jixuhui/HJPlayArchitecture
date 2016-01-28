//
//  BarControllerContentViewController.m
//  HJDemo
//
//  Created by jixuhui on 15/11/12.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "BarControllerContentViewController.h"
#import "DemoManager.h"

@interface BarControllerContentViewController ()

@end

@implementation BarControllerContentViewController
@synthesize padding = _padding;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    RDVTabBarController *rdv_tabBarController = [DemoManager shareManager].tabBarContoller;
    float tabBarH = 0;
    if (rdv_tabBarController.tabBar.translucent) {
        tabBarH = CGRectGetHeight(self.rdv_tabBarController.tabBar.frame);
    }
    self.padding = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTabBarHidden:NO animated:YES];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if ([DemoManager shareManager].tabBarContoller.tabBar.isHidden != hidden) {
        [[DemoManager shareManager].tabBarContoller setTabBarHidden:hidden animated:animated];
    }
}

#pragma mark - help methods

- (void)showSimpleAlertByMessgae:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:message delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
    [alert show];
}

@end
