//
//  AppDelegate.m
//  HJDemo
//
//  Created by jixuhui on 15/10/30.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "AppDelegate.h"

#import "HJArchitecture.h"

#import "RDVTabBarItem.h"
#import "RDVTabBar.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

#import "MASViewController.h"

#import "DemoManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createItemsWithIcons];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self setupViewControllers];
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    
    [self customizeInterface];
    
    return YES;
}

#pragma mark - Methods

- (void)setupViewControllers {
    UIViewController *firstViewController = [[FirstViewController alloc] init];
    UIViewController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:firstViewController];
    
    UIViewController *secondViewController = [[SecondViewController alloc] init];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:secondViewController];
    
    UIViewController *thirdViewController = [[ThirdViewController alloc] init];
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:thirdViewController];
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    
    [tabBarController setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController]];
    
    [DemoManager shareManager].tabBarContoller = tabBarController;
    
    self.tabBarController = tabBarController;
    
    [self customizeTabBarForController:tabBarController];
    
    
//    [self.tabBarController setSelectedIndex:2];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
//    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
//    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"first", @"second", @"third"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
//        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        item.title = [tabBarItemImages objectAtIndex:index];
        
        item.selectedTitleAttributes = @{
                                         NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                         NSForegroundColorAttributeName:[UIColor greenColor],
                                         };
        
        item.unselectedTitleAttributes = @{
                                           NSFontAttributeName: [UIFont systemFontOfSize:12],
                                           NSForegroundColorAttributeName:[UIColor blackColor],
                                           };
        
        index++;
    }
    
    RDVTabBar *tabBar = tabBarController.tabBar;
    
    tabBar.translucent = YES;
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}

#pragma mark - other delegate

- (BOOL)application:(nonnull UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * __nullable))restorationHandler{
    
    NSLog(@"idetifier...%@",userActivity);
    
    [self.tabBarController setSelectedIndex:0];
    
    MASViewController *masVC = [[MASViewController alloc]init];
    [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:masVC animated:YES];
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    NSLog(@"A shortcut item was pressed. It was %@.", shortcutItem.localizedTitle);
    
    [self launchViewControllerWithType:shortcutItem.type];
    
}

- (void)launchViewControllerWithType:(NSString *)type
{
    if (CHECK_VALID_STRING(type)) {
        NSArray *typeSepArr = [type componentsSeparatedByString:@"."];
        
        if (CHECK_VALID_ARRAY(typeSepArr)&&[typeSepArr count]==3) {
            NSString *identifier = [typeSepArr lastObject];
            
            [self.tabBarController setSelectedIndex:[identifier integerValue]];
            
        }
    }else{
        NSLog(@"type is error info!");
    }
}

#pragma mark - other methods

- (void)createItemsWithIcons {
    
    // icons with my own images
    UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"home_screen_search"];
    UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"home_screen_hot"];
    UIApplicationShortcutIcon *icon3 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"home_screen_tuijian"];
    
    UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"com.demo.0" localizedTitle:@"搜索" localizedSubtitle:@"" icon:icon1 userInfo:nil];
    UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"com.demo.1" localizedTitle:@"今日热点" localizedSubtitle:@"" icon:icon2 userInfo:nil];
    UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"com.demo.2" localizedTitle:@"推荐新闻" localizedSubtitle:@"" icon:icon3 userInfo:nil];
    
    // add all items to an array
    NSArray *items = @[item1, item2, item3];
    
    // add this array to the potentially existing static UIApplicationShortcutItems
//    NSArray *existingItems = [UIApplication sharedApplication].shortcutItems;
//    NSArray *updatedItems = [existingItems arrayByAddingObjectsFromArray:items];
    [UIApplication sharedApplication].shortcutItems = items;
    
}

@end
